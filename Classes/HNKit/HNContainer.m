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

- (void)loadFromDictionary:(NSDictionary *)dictionary complete:(BOOL)complete {
    [self setMoreToken:[dictionary objectForKey:@"more"]];

    [super loadFromDictionary:dictionary complete:complete];
}

- (void)loadMoreFromDictionary:(NSDictionary *)dictionary complete:(BOOL)complete {
    NSArray *previousEntries = [[[self entries] retain] autorelease];
    [self loadFromDictionary:dictionary complete:complete];
    NSArray *combinedEntries = [previousEntries arrayByAddingObjectsFromArray:[self entries]];
    [self setEntries:combinedEntries];
}

- (BOOL)isLoadingMore {
    return [self hasLoadingState:kHNContainerLoadingStateLoadingMore];
}

- (void)beginLoadingMore {
    if ([self isLoadingMore] || moreToken == nil || ![self isLoaded]) return;
    
    [self addLoadingState:kHNContainerLoadingStateLoadingMore];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:moreToken forKey:@"fnid"];
    
    moreRequest = [[HNAPIRequest alloc] initWithSession:session target:self action:@selector(moreRequest:completedWithResponse:error:)];
    [moreRequest performRequestWithPath:@"x" parameters:parameters];
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
