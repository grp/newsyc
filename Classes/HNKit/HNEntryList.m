//
//  HNEntryList.m
//  newsyc
//
//  Created by Grant Paul on 8/12/11.
//  Copyright (c) 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNEntryList.h"
#import "HNEntry.h"

@interface HNEntryList ()

@property (nonatomic, retain) HNUser *user;

@end

@implementation HNEntryList
@synthesize user;

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

- (void)loadFromDictionary:(NSDictionary *)response entries:(NSArray **)outEntries {
    NSMutableArray *children = [NSMutableArray array];
    
    for (NSDictionary *entryDictionary in [response objectForKey:@"children"]) {
        HNEntry *entry = [HNEntry entryWithIdentifier:[entryDictionary objectForKey:@"identifier"]];
        [entry loadFromDictionary:entryDictionary];
        [children addObject:entry];
        
        // XXX: should the entry be set to loaded here? probably not, since
        //      it isn't fully loaded (as the loaded state represents).
    }

    if (outEntries != NULL) {
        *outEntries = children;
    }
}

@end
