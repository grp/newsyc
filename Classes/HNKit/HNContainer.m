//
//  HNContainer.m
//  newsyc
//
//  Created by Grant Paul on 2/25/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "HNContainer.h"
#import "HNAPIRequest.h"
#import "HNEntry.h"

@implementation HNContainer
@synthesize entries, moreToken;

- (BOOL)isLoadingMore {
    return [self hasLoadingState:kHNContainerLoadingStateLoadingMore];
}

- (void)beginLoadingMore {
    if ([self isLoadingMore] || moreToken == nil || ![self isLoaded]) return;
    
    [self addLoadingState:kHNContainerLoadingStateLoadingMore];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:moreToken forKey:@"fnid"];
    
    moreRequest = [[HNAPIRequest alloc] initWithTarget:self action:@selector(moreRequest:completedWithResponse:error:)];
    [moreRequest performRequestWithPath:@"x" parameters:parameters];
}

- (void)loadContentsDictionary:(NSDictionary *)contents entries:(NSArray **)outEntries {
    return;
}

- (void)loadContentsDictionary:(NSDictionary *)contents {
    NSArray *children = nil;
    [self loadContentsDictionary:contents entries:&children];

    if ([[contents objectForKey:@"append"] boolValue]) {
        [self setEntries:[entries arrayByAddingObjectsFromArray:children]];
    } else {
        [self setEntries:children];
    }

    [self setMoreToken:[contents objectForKey:@"more"]];

    [super loadContentsDictionary:contents];
}

- (void)loadContentsDictionary:(NSDictionary *)contents append:(BOOL)append {
    NSMutableDictionary *mutableContents = [[contents mutableCopy] autorelease];
    [mutableContents setObject:[NSNumber numberWithBool:append] forKey:@"append"];
    [self loadContentsDictionary:mutableContents];
}

- (NSDictionary *)contentsDictionary {
    NSMutableDictionary *dictionary = [[[super contentsDictionary] mutableCopy] autorelease];

    if (moreToken != nil) [dictionary setObject:moreToken forKey:@"more"];

    NSMutableArray *children = [NSMutableArray array];
    for (HNEntry *child in entries) {
        [children addObject:[child contentsDictionary]];
    }
    [dictionary setObject:children forKey:@"children"];

    return dictionary;
}

- (void)cancelLoadingMore {
    [self clearLoadingState:kHNContainerLoadingStateLoadingMore];
    [moreRequest cancelRequest];
    [moreRequest release];
    moreRequest = nil;
}

- (void)beginLoadingWithState:(HNObjectLoadingState)state_ {
    [self cancelLoadingMore];
    [super beginLoadingWithState:state_];
}

- (void)moreRequest:(HNAPIRequest *)request completedWithResponse:(NSDictionary *)response error:(NSError *)error {
    [self clearLoadingState:kHNContainerLoadingStateLoadingMore];
    [moreRequest release];
    moreRequest = nil;
    
    if (error == nil) {
        [self loadContentsDictionary:response append:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kHNObjectFinishedLoadingNotification object:self];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHNObjectFailedLoadingNotification object:self];
    }
}

- (void)finishLoadingWithResponse:(NSDictionary *)response error:(NSError *)error {
    if (error == nil) {
        [self loadContentsDictionary:response append:NO];
    }
}

@end
