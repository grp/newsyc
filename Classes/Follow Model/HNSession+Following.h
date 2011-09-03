//
//  HNSession+Following.h
//  newsyc
//
//  Created by Grant Paul on 8/21/11.
//  Copyright (c) 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"

#ifdef ENABLE_TIMELINE

#define kHNSessionUserFollowedUsersChangedNotification @"HNSessionUserFollowedUsersChanged"

@interface HNSession (Following)

@property (nonatomic, readonly) NSSet *usersFollowed;

- (void)followUser:(HNUser *)user;
- (void)unfollowUser:(HNUser *)user;

@end

#endif
