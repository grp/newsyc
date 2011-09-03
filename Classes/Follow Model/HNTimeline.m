//
//  HNTimeline.m
//  newsyc
//
//  Created by Grant Paul on 8/21/11.
//  Copyright (c) 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNTimeline.h"
#import "HNSession+Following.h"

#ifdef ENABLE_TIMELINE

@interface HNTimeline ()

@property (nonatomic, retain) HNSession *session;

@end

@implementation HNTimeline
@synthesize session;

+ (HNTimeline *)timelineForSession:(HNSession *)session {
    HNTimeline *timeline = [self entryListWithIdentifier:kHNEntryListIdentifierTimeline];
    [timeline setSession:session];
    return timeline;
}

- (NSURL *)URL {
    return nil;
}

- (id)init {
    if ((self = [super init])) {
        loadingUsers = [[NSMutableSet alloc] init];
        loadedUsers = [[NSMutableSet alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [loadingUsers release];
    [loadedUsers release];
    [session release];
    
    [super dealloc];
}

- (void)userFinishedLoadingWithNotification:(NSNotification *)notification {
    HNEntryList *list = (HNEntryList *) [notification object];
    [loadingUsers removeObject:list];
    [loadedUsers addObject:list];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHNObjectFinishedLoadingNotification object:list];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHNObjectFailedLoadingNotification object:list];

    if ([loadingUsers count] == 0) {
        NSMutableArray *comments = [NSMutableArray array];
        
        for (HNEntryList *list in loadedUsers) {
            [comments addObjectsFromArray:[list entries]];
        }
        
        [self setEntries:[comments sortedArrayUsingSelector:@selector(posted)]];
        
        [loadingUsers removeAllObjects];
        [loadedUsers removeAllObjects];
        
        [self setIsLoaded:YES];
    }
}

- (void)userFailedLoadingWithNotification:(NSNotification *)notification {
    HNEntryList *list = (HNEntryList *) [notification object];
    [loadingUsers removeObject:list];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHNObjectFinishedLoadingNotification object:list];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHNObjectFailedLoadingNotification object:list];
    
    [self cancelLoading];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHNObjectFailedLoadingNotification object:self];
}

- (void)cancelLoading {
    for (HNEntryList *list in loadingUsers) {
        [list cancelLoading];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kHNObjectFinishedLoadingNotification object:list];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kHNObjectFailedLoadingNotification object:list];
    }
    
    [loadingUsers removeAllObjects];
    [loadedUsers removeAllObjects];
}

- (void)beginLoadingWithState:(HNObjectLoadingState)state_ {
    [self addLoadingState:state_];
    
    if ([[session usersFollowed] count] == 0) {
        [self setIsLoaded:YES];
        
        return;
    }
    
    for (HNUser *user_ in [session usersFollowed]) {
        HNEntryList *list = [HNEntryList entryListWithIdentifier:kHNEntryListIdentifierUserComments user:user_];
        [loadingUsers addObject:list];
        
        // In case this ends loading before this method finishes executing, have
        // this run on the next iteration of the runloop, just to be safe.
        [list beginLoading];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFinishedLoadingWithNotification:) name:kHNObjectFinishedLoadingNotification object:list];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFailedLoadingWithNotification:) name:kHNObjectFailedLoadingNotification object:list];
    }
}

- (void)setSession:(HNSession *)session_ {
    [session autorelease];
    session = [session_ retain];
}

@end

#endif
