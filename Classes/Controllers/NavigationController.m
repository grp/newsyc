//
//  NavigationController.m
//  newsyc
//
//  Created by Grant Paul on 3/29/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "NavigationController.h"

#import "LoginController.h"
#import "HackerNewsLoginController.h"

@implementation NavigationController
@synthesize loginDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];

    [super dealloc];
}

- (void)enteredForeground {
    [self viewWillAppear:NO];
    [self viewDidAppear:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disable-orange"]) {
        [[self navigationBar] setTintColor:[UIColor colorWithRed:1.0f green:0.4f blue:0.0f alpha:1.0f]];
    } else {
        [[self navigationBar] setTintColor:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (loginDelegatePendingSession != nil) {
        [loginDelegate navigationController:self didLoginWithSession:loginDelegatePendingSession];
        [loginDelegatePendingSession release];
        loginDelegatePendingSession = nil;
    }
}

// Why this isn't delegated by UIKit to the top view controller, I have no clue.
// This, however, should unobstrusively add that delegation.
- (UIModalPresentationStyle)modalPresentationStyle {
    UIModalPresentationStyle style = [super modalPresentationStyle];
    
    if (style != UIModalPresentationFullScreen) {
        return style;
    } else if ([self topViewController]) {
        return [[self topViewController] modalPresentationStyle];
    } else {
        return style;
    }
}

- (void)loginControllerDidLogin:(HackerNewsLoginController *)controller {
    [self dismissModalViewControllerAnimated:YES];

    loginDelegatePendingSession = [[controller session] retain];
}

- (void)loginControllerDidCancel:(HackerNewsLoginController *)controller {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)requestLogin {
    LoginController *login = [[HackerNewsLoginController alloc] init];
    [login setDelegate:self];

    NavigationController *navigation = [[NavigationController alloc] initWithRootViewController:login];
    [self presentModalViewController:navigation animated:YES];

    [navigation release];
    [login release];
}


AUTOROTATION_FOR_PAD_ONLY

@end
