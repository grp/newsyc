//
//  HackerNewsLoginController.m
//  newsyc
//
//  Created by Grant Paul on 4/6/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HackerNewsLoginController.h"

@implementation HackerNewsLoginController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [topLabel setText:@"Hacker News"];
    [topLabel setTextColor:[UIColor whiteColor]];
    [topLabel setShadowColor:[UIColor blackColor]];
    [bottomLabel setText:@"Your info is only shared with Hacker News."];
    [bottomLabel setTextColor:[UIColor whiteColor]];
}

- (BOOL)requiresPassword {
    return YES;
}

- (void)sessionAuthenticatorDidRecieveFailure:(HNSessionAuthenticator *)authenticator {
    [authenticator autorelease];
    [self finish];
    [self fail];
}

- (void)sessionAuthenticator:(HNSessionAuthenticator *)authenticator didRecieveToken:(HNSessionToken)token {
    HNSession *session = [[HNSession alloc] initWithUsername:[usernameField text] password:[passwordField text] token:token];
    [HNSession setCurrentSession:[session autorelease]];
    [authenticator autorelease];
    
    [self finish];
    [self succeed];
}

- (NSArray *)gradientColors {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:(id) [[UIColor colorWithRed:1.0f green:0.6f blue:0.2f alpha:1.0f] CGColor]];
    [array addObject:(id) [[UIColor colorWithRed:0.4f green:0.1f blue:0.0f alpha:1.0f] CGColor]];
    return array;
}

- (void)authenticate {
	[super authenticate];
    HNSessionAuthenticator *authenticator = [[HNSessionAuthenticator alloc] initWithUsername:[usernameField text] password:[passwordField text]];
    [authenticator setDelegate:self];
    [authenticator beginAuthenticationRequest];
}

AUTOROTATION_FOR_PAD_ONLY

@end
