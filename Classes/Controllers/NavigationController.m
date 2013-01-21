//
//  NavigationController.m
//  newsyc
//
//  Created by Grant Paul on 3/29/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "ModalNavigationController.h"
#import "NavigationController.h"

#import "SplitViewController.h"

#import "LoginController.h"
#import "UIColor+Orange.h"
#import "HackerNewsLoginController.h"

#import "MainTabBarController.h"
#import "SessionListController.h"
#import "SearchController.h"
#import "ProfileController.h"
#import "MoreController.h"
#import "SubmissionListController.h"
#import "SessionListController.h"
#import "ComposeController.h"

@implementation NavigationController
@synthesize loginDelegate;

- (BOOL)controllerBelongsOnLeft:(UIViewController *)controller {
    return [controller isKindOfClass:[MainTabBarController class]]
    || [controller isKindOfClass:[SessionListController class]]
    || [controller isKindOfClass:[SearchController class]]
    || [controller isKindOfClass:[ProfileController class]]
    || [controller isKindOfClass:[MoreController class]]
    || [controller isKindOfClass:[SubmissionListController class]];
}

- (BOOL)controllerRequiresClearing:(UIViewController *)controller {
    return [controller isKindOfClass:[SessionListController class]];
}

- (BOOL)controllerBelongsPresented:(UIViewController *)controller {
    if ([controller isKindOfClass:[LoginController class]]) {
        return YES;
    } else if ([controller isKindOfClass:[ComposeController class]]) {
        return YES;
    }

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return [controller isKindOfClass:[ProfileController class]];
    } else {
        return NO;
    }
}

- (SplitViewController *)splitController {
    return (SplitViewController *) [self splitViewController];
}

- (void)popToController:(UIViewController *)controller animated:(BOOL)animated {
    if ([self splitController] != nil) {
        if ([[self viewControllers] containsObject:controller]) {
            [[self splitController] popBranchToViewController:controller animated:animated];
        } else if ([[self splitController] leafContainsViewController:controller]) {
            [[self splitController] popLeafToViewController:controller animated:animated];
        } else {
            [NSException raise:@"UINavigationControllerPopException" format:@"can't find where to pop"];
        }
    } else {
        [self popToViewController:controller animated:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self controllerRequiresClearing:viewController]) {
        if ([self splitController] != nil) {
            [[self splitController] clearLeafViewControllerAnimated:animated];
        }
    }
}

- (void)pushController:(UIViewController *)controller animated:(BOOL)animated {
    if ([self presentingViewController] != nil) {
        if (![self controllerBelongsOnLeft:controller]) {
            UIViewController *bottomController = [self presentingViewController];

            // If we are a stacked modal controller, push on the bottom controller.
            while ([bottomController presentingViewController] != nil) {
                bottomController = [bottomController presentingViewController];
            }

            if ([bottomController isKindOfClass:[NavigationController class]]) {
                NavigationController *navigationController = (NavigationController *) bottomController;
                [navigationController pushController:controller animated:animated];
            } else if ([bottomController isKindOfClass:[SplitViewController class]]) {
                SplitViewController *splitController = (SplitViewController *) bottomController;
                [splitController pushLeafViewController:controller animated:animated];
            }

            [self dismissViewControllerAnimated:animated completion:NULL];
        } else {
            [self pushViewController:controller animated:animated];
        }
    } else if ([self controllerBelongsPresented:controller]) {
        NavigationController *navigation = [[NavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:navigation animated:animated completion:NULL];
        [navigation release];
    } else {
        if ([self splitViewController] != nil) {
            if ([self controllerBelongsOnLeft:controller]) {
                [[self splitController] pushBranchViewController:controller animated:animated];
            } else if ([self controllerBelongsOnLeft:[self topViewController]]) {
                [[self splitController] setLeafViewController:controller animated:animated];
            } else {
                [[self splitController] pushLeafViewController:controller animated:animated];
            }
        } else {
            [self pushViewController:controller animated:animated];
        }
    }
}

- (void)setLoginDelegate:(id<NavigationControllerLoginDelegate>)delegate {
    loginDelegate = delegate;

    if ([self splitController] != nil) {
        NSArray *viewControllers = [[self splitController] viewControllers];
        NavigationController *rightNavigationController = [viewControllers lastObject];
        
        if (rightNavigationController != self) {
            [rightNavigationController setLoginDelegate:delegate];
        }
    }
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setDelegate:self];
    
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

#pragma mark - Login

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
    [self pushController:login animated:YES];
    [login release];
}

- (void)requestSessions {
    [loginDelegate navigationControllerRequestedSessions:self];
}

AUTOROTATION_FOR_PAD_ONLY

@end
