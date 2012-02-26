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

- (void)loadFromDictionary:(NSDictionary *)response entries:(NSArray **)outEntries {
    return;
}

- (void)loadFromDictionary:(NSDictionary *)response {
    [self loadFromDictionary:response entries:NULL];
}

- (void)loadFromDictionary:(NSDictionary *)response append:(BOOL)append {
    NSArray *children = nil;
    [self loadFromDictionary:response entries:&children];
    
    if (append) {
        [self setEntries:[entries arrayByAddingObjectsFromArray:children]];
    } else {
        [self setEntries:children];
    }
    
    [self setMoreToken:[response objectForKey:@"more"]];
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
        [self loadFromDictionary:response append:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kHNObjectFinishedLoadingNotification object:self];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHNObjectFailedLoadingNotification object:self];
    }
}

- (void)finishLoadingWithResponse:(NSDictionary *)response error:(NSError *)error {
    if (error == nil) {
        [self loadFromDictionary:response append:NO];
    }
}

@end
