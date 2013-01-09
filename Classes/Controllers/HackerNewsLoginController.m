//
//  HackerNewsLoginController.m
//  newsyc
//
//  Created by Grant Paul on 4/6/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HackerNewsLoginController.h"

@implementation HackerNewsLoginController
@synthesize session;

- (void)viewDidLoad {
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
    session = [[HNSession alloc] initWithUsername:[usernameField text] password:[passwordField text] token:token];
    [[HNSessionController sessionController] addSession:session];
    [authenticator autorelease];
    
    [self finish];
    [self succeed];
}

- (void)dealloc {
    [session release];
    
    [super dealloc];
}

- (NSArray *)gradientColors {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:(id) [[UIColor colorWithRed:1.0f green:0.6f blue:0.2f alpha:1.0f] CGColor]];
    [array addObject:(id) [[UIColor colorWithRed:0.4f green:0.1f blue:0.0f alpha:1.0f] CGColor]];
    return array;
}

- (void)authenticate {
	[super authenticate];

    NSString *username = [usernameField text];

    for (HNSession *session_ in [[HNSessionController sessionController] sessions]) {
        if ([[session_ identifier] isEqual:username]) {
            [self finish];
            [self fail];
            return;
        }
    }
    
    HNSessionAuthenticator *authenticator = [[HNSessionAuthenticator alloc] initWithUsername:username password:[passwordField text]];
    [authenticator setDelegate:self];
    [authenticator beginAuthenticationRequest];
}

AUTOROTATION_FOR_PAD_ONLY

@end
