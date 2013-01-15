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

#import "NSURL+Parameters.h"

@implementation HNContainer
@synthesize entries, moreToken;

- (void)loadFromDictionary:(NSDictionary *)dictionary complete:(BOOL)complete {
    [self setMoreToken:[dictionary objectForKey:@"more"]];

    [super loadFromDictionary:dictionary complete:complete];
}

- (void)loadMoreFromDictionary:(NSDictionary *)dictionary complete:(BOOL)complete {
    pendingMoreEntries = [[self entries] retain];
    [self loadFromDictionary:dictionary complete:complete];
    [pendingMoreEntries release];
    pendingMoreEntries = nil;
}

- (BOOL)isLoadingMore {
    return [self hasLoadingState:kHNContainerLoadingStateLoadingMore];
}

- (void)beginLoadingMore {
    if ([self isLoadingMore] || moreToken == nil || ![self isLoaded]) return;
    
    [self addLoadingState:kHNContainerLoadingStateLoadingMore];

    NSURL *moreURL = [NSURL URLWithString:moreToken];
    
    NSString *path = [moreURL path];
    if ([path hasPrefix:@"/"]) path = [path substringFromIndex:[@"/" length]];
    NSDictionary *parameters = [moreURL parameterDictionary];
    if (parameters == nil) parameters = [NSDictionary dictionary];
    
    moreRequest = [[HNAPIRequest alloc] initWithSession:session target:self action:@selector(moreRequest:completedWithResponse:error:)];
    [moreRequest performRequestWithPath:path parameters:parameters];
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
        [self loadMoreFromDictionary:response complete:YES];

        [[NSNotificationCenter defaultCenter] postNotificationName:kHNObjectFinishedLoadingNotification object:self];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHNObjectFailedLoadingNotification object:self];
    }
}

@end
