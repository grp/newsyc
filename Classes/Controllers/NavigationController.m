//
//  NavigationController.m
//  newsyc
//
//  Created by Grant Paul on 3/29/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "NavigationController.h"

#import "LoginController.h"
#import "UIColor+Orange.h"
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
        [[self navigationBar] setTintColor:[UIColor mainOrangeColor]];
    } else {
        [[self navigationBar] setTintColor:nil];
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
    [self dismissViewControllerAnimated:YES completion:^{
        [loginDelegate navigationController:self didLoginWithSession:[controller session]];
    }];
}

- (void)loginControllerDidCancel:(HackerNewsLoginController *)controller {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)requestLogin {
    LoginController *login = [[HackerNewsLoginController alloc] init];
    [login setDelegate:self];

    NavigationController *navigation = [[NavigationController alloc] initWithRootViewController:login];
    [self presentViewController:navigation animated:YES completion:NULL];

    [navigation release];
    [login release];
}

- (void)requestSessions {
    [loginDelegate navigationControllerRequestedSessions:self];
}

AUTOROTATION_FOR_PAD_ONLY

@end
