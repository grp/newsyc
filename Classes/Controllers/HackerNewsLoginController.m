//
//  HackerNewsLoginController.m
//  newsyc
//
//  Created by Grant Paul on 4/6/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HackerNewsLoginController.h"

#import "UIColor+Orange.h"

@implementation HackerNewsLoginController
@synthesize session;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [topLabel setText:@"Hacker News"];
    [bottomLabel setText:@"Your info is only shared with Hacker News."];

    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        [topLabel setTextColor:[UIColor blackColor]];
        [bottomLabel setTextColor:[UIColor darkGrayColor]];

        [topLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:34.0]];
    } else {
        [topLabel setTextColor:[UIColor whiteColor]];
        [topLabel setShadowColor:[UIColor blackColor]];
        [bottomLabel setTextColor:[UIColor whiteColor]];

        [topLabel setFont:[UIFont boldSystemFontOfSize:30.0f]];
        [topLabel setShadowOffset:CGSizeMake(0, 1.0f)];
    }

    [bottomLabel setFont:[UIFont systemFontOfSize:14.0f]];
}

- (BOOL)requiresPassword {
    return YES;
}

- (void)sessionAuthenticatorDidRecieveFailure:(HNSessionAuthenticator *)authenticator {
    [self finish];
    [self fail];
}

- (void)sessionAuthenticator:(HNSessionAuthenticator *)authenticator didRecieveToken:(HNSessionToken)token {
    session = [[HNSession alloc] initWithUsername:[usernameField text] password:[passwordField text] token:token];
    [[HNSessionController sessionController] addSession:session];
    
    [self finish];
    [self succeed];
}


- (NSArray *)gradientColors {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:(id) [[UIColor lightOrangeColor] CGColor]];
    [array addObject:(id) [[UIColor mainOrangeColor] CGColor]];
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
