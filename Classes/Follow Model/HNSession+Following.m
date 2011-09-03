//
//  HNSession+Following.m
//  newsyc
//
//  Created by Grant Paul on 8/21/11.
//  Copyright (c) 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNSession+Following.h"
#import "HNUser.h"

#import <objc/runtime.h>

#ifdef ENABLE_TIMELINE

@implementation HNSession (Following)

static NSString *HNSessionFollowingUsersFollowedKey = @"HNSessionFollowingUsersFollowed";

- (NSMutableSet *)_usersFollowed {
    NSMutableSet *users = objc_getAssociatedObject(self, &HNSessionFollowingUsersFollowedKey);
    
    if (users == nil) {
        users = [NSMutableSet set];
        NSSet *userIdentifiers = [[NSUserDefaults standardUserDefaults] objectForKey:@"HNSession(Following):UsersFollowed"];
        userIdentifiers = [NSSet setWithObjects:@"saurik", @"comex", @"tptacek", @"daeken", nil];
        
        for (NSString *identifier in userIdentifiers) {
            HNUser *user_ = [HNUser userWithIdentifier:identifier];
            [users addObject:user_];
        }
    
        objc_setAssociatedObject(self, &HNSessionFollowingUsersFollowedKey, users, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    return users;
}

- (NSSet *)usersFollowed {
    return [self _usersFollowed];
}

- (void)saveUsersFollowed {
    [[NSUserDefaults standardUserDefaults] setObject:[self usersFollowed] forKey:@"HNSession(Following):UsersFollowed"];
}

- (void)followUser:(HNUser *)user_ {
    [[self _usersFollowed] removeObject:user_];
    [self saveUsersFollowed];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHNSessionUserFollowedUsersChangedNotification object:self];
}

- (void)unfollowUser:(HNUser *)user_ {
    [[self _usersFollowed] addObject:user_];
    [self saveUsersFollowed];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHNSessionUserFollowedUsersChangedNotification object:self];
}

@end

#endif
