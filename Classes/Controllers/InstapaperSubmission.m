//
//  InstapaperSubmission.m
//  newsyc
//
//  Created by Grant Paul on 10/30/12.
//
//

#import "InstapaperSubmission.h"

#import "InstapaperSession.h"
#import "InstapaperRequest.h"

#import "NavigationController.h"
#import "InstapaperLoginController.h"

#import "ProgressHUD.h"

@interface InstapaperSubmission () <LoginControllerDelegate>
@end

@implementation InstapaperSubmission
@synthesize loginCompletion;

- (id)initWithURL:(NSURL *)url_ {
    if ((self = [super init])) {
        url = [url_ copy];
    }

    return self;
}


- (void)submitInstapaperRequest {
    InstapaperRequest *request = [[InstapaperRequest alloc] initWithSession:[InstapaperSession currentSession]];

    ProgressHUD *hud = [[ProgressHUD alloc] init];
    [hud setText:@"Saving"];
    [hud showInWindow:[[UIApplication sharedApplication] keyWindow]];

    // Yes, really: this allows callers to fire-and-forget, and then we disappear on completion.

    __weak id succeededObserver = nil;
    [[NSNotificationCenter defaultCenter] addObserverForName:kInstapaperRequestSucceededNotification object:request queue:nil usingBlock:^(NSNotification *notification) {
        [hud setText:@"Saved!"];
        [hud setState:kProgressHUDStateCompleted];
        [hud dismissAfterDelay:0.8f animated:YES];

        [[NSNotificationCenter defaultCenter] removeObserver:succeededObserver];
    }];

    __weak id failedObserver = nil;
    failedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kInstapaperRequestFailedNotification object:request queue:nil usingBlock:^(NSNotification *notification) {
        [hud setText:@"Error Saving"];
        [hud setState:kProgressHUDStateError];
        [hud dismissAfterDelay:0.8f animated:YES];

        [[NSNotificationCenter defaultCenter] removeObserver:failedObserver];
    }];

    [request addItemWithURL:url];
}

- (UIViewController *)submitFromController:(UIViewController *)controller {
    if ([InstapaperSession currentSession] != nil) {
        [self submitInstapaperRequest];
        return nil;
    } else {
        InstapaperLoginController *login = [[InstapaperLoginController alloc] init];
        [login setPendingURL:url];
        [login setDelegate:self];

        NavigationController *navigation = [[NavigationController alloc] initWithRootViewController:login];
        if (controller != nil) {
            presented = YES;

            [controller presentViewController:navigation animated:YES completion:NULL];
        }

        return navigation;
    }
}

- (void)dismissLoginController:(InstapaperLoginController *)controller loggedIn:(BOOL)loggedIn {
    if (presented) {
        presented = NO;

        [controller dismissViewControllerAnimated:YES completion:NULL];
    }

    if (loginCompletion != NULL) {
        loginCompletion(loggedIn);

        loginCompletion = nil;
    }
}

- (void)loginControllerDidLogin:(InstapaperLoginController *)controller {
    [self submitInstapaperRequest];
    [self dismissLoginController:controller loggedIn:YES];
}

- (void)loginControllerDidCancel:(InstapaperLoginController *)controller {
    [self dismissLoginController:controller loggedIn:NO];
}

@end
