//
//  HNEntryList.m
//  newsyc
//
//  Created by Grant Paul on 8/12/11.
//  Copyright (c) 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNEntryList.h"

#import "NSURL+Parameters.h"

@interface HNEntryList ()

@property (nonatomic, retain) HNUser *user;

@end

@implementation HNEntryList
@synthesize entries, user, moreToken;

+ (NSDictionary *)infoDictionaryForURL:(NSURL *)url_ {
    if (![self isValidURL:url_]) return nil;

    NSDictionary *parameters = [url_ parameterDictionary];
    if ([parameters objectForKey:@"id"] != nil) return [NSDictionary dictionaryWithObject:[parameters objectForKey:@"id"] forKey:@"user"];
    else return nil;
}

+ (id)identifierForURL:(NSURL *)url_ {
    if (![self isValidURL:url_]) return nil;
    
    NSString *path = [url_ path];
    if ([path hasSuffix:@"/"]) path = [path substringToIndex:[path length] - 2];
    
    return path;
}

+ (NSString *)pathForURLWithIdentifier:(id)identifier_ infoDictionary:(NSDictionary *)info {
    return identifier_;
}

+ (NSDictionary *)parametersForURLWithIdentifier:(id)identifier_ infoDictionary:(NSDictionary *)info {
    if (info != nil && [info objectForKey:@"user"] != nil) {
        return [NSDictionary dictionaryWithObject:[info objectForKey:@"user"] forKey:@"id"];
    } else {
        return [NSDictionary dictionary];
    }
}

+ (id)entryListWithIdentifier:(HNEntryListIdentifier)identifier_ {
    return [self entryListWithIdentifier:identifier_ user:nil];
}

+ (id)entryListWithIdentifier:(HNEntryListIdentifier)identifier_ user:(HNUser *)user_ {
    NSDictionary *info = nil;
    if (user_ != nil) info = [NSDictionary dictionaryWithObject:[user_ identifier] forKey:@"user"];
    
    return [self objectWithIdentifier:identifier_ infoDictionary:info];
}

- (void)loadInfoDictionary:(NSDictionary *)info {
    if (info != nil) {
        NSString *identifier_ = [info objectForKey:@"user"];
        [self setUser:[HNUser userWithIdentifier:identifier_]];
    }
}

- (NSDictionary *)infoDictionary {
    if (user != nil) {
        return [NSDictionary dictionaryWithObject:[user identifier] forKey:@"user"];
    } else {
        return [super infoDictionary];
    }
}

- (void)beginLoadingMore {
    if ([self isLoadingMore] || moreToken == nil || ![self isLoaded]) return;
    
    [self addLoadingState:kHNEntryListLoadingStateLoadingMore];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:moreToken forKey:@"fnid"];
    
    moreRequest = [[HNAPIRequest alloc] initWithTarget:self action:@selector(moreRequest:completedWithResponse:error:)];
    [moreRequest performRequestWithPath:@"x" parameters:parameters];
}

- (void)loadFromDictionary:(NSDictionary *)response appendChildren:(BOOL)append {
    NSMutableArray *children = [NSMutableArray array];
    
    for (NSDictionary *entryDictionary in [response objectForKey:@"children"]) {
        HNEntry *entry = [HNEntry entryWithIdentifier:[entryDictionary objectForKey:@"identifier"]];
        [entry loadFromDictionary:entryDictionary];
        [children addObject:entry];
        
        // XXX: should the entry be set to loaded here? probably not, since
        //      it isn't fully loaded (as the loaded state represents).
    }
    
    if (append) {
        [self setEntries:[entries arrayByAddingObjectsFromArray:children]];
    } else {
        [self setEntries:children];
    }
    
    [self setMoreToken:[response objectForKey:@"more"]];
}

- (BOOL)isLoadingMore {
    return [self hasLoadingState:kHNEntryListLoadingStateLoadingMore];
}

- (void)cancelLoadingMore {
    [self clearLoadingState:kHNEntryListLoadingStateLoadingMore];
    [moreRequest cancelRequest];
    [moreRequest release];
    moreRequest = nil;
}

- (void)beginLoadingWithState:(HNObjectLoadingState)state_ {
    [self cancelLoadingMore];
    [super beginLoadingWithState:state_];
}

- (void)moreRequest:(HNAPIRequest *)request completedWithResponse:(NSDictionary *)response error:(NSError *)error {
    [self clearLoadingState:kHNEntryListLoadingStateLoadingMore];
    [moreRequest release];
    moreRequest = nil;
    
    if (error == nil) {
        [self loadFromDictionary:response appendChildren:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kHNObjectFinishedLoadingNotification object:self];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHNObjectFailedLoadingNotification object:self];
    }
}

- (void)finishLoadingWithResponse:(NSDictionary *)response error:(NSError *)error {
    if (error == nil) {
        [self loadFromDictionary:response appendChildren:NO];
    }
}

@end
