//
//  HNAnonymousSession.m
//  newsyc
//
//  Created by Grant Paul on 4/13/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"
#import "HNAnonymousSession.h"
#import "HNSubmission.h"

@implementation HNSession (HNAnonymousSession)

- (BOOL)isAnonymous {
    return NO;
}

@end

@implementation HNAnonymousSession

- (void)performSubmission:(HNSubmission *)submission target:(id)target action:(SEL)action {
    [target performSelector:action withObject:nil withObject:[NSNumber numberWithBool:NO]];
}

- (BOOL)isAnonymous {
    return YES;
}

- (void)reloadToken {
    // do nothing
}

@end
