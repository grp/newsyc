//
//  InstapaperController.m
//  newsyc
//
//  Created by Grant Paul on 2/24/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "InstapaperController.h"

#import "InstapaperLoginController.h"
#import "InstapaperRequest.h"
#import "InstapaperSession.h"

#import "NavigationController.h"
#import "ProgressHUD.h"

@implementation InstapaperController

+ (id)sharedInstance {
    static InstapaperController *shared = nil;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        shared = [[InstapaperController alloc] init];
    });
    
    return shared;
}

- (void)submitInstapaperRequestForURL:(NSURL *)url {
    InstapaperRequest *request = [[InstapaperRequest alloc] initWithSession:[InstapaperSession currentSession]];
    
    ProgressHUD *hud = [[ProgressHUD alloc] init];
    [hud setText:@"Saving"];
    [hud showInWindow:[[UIApplication sharedApplication] keyWindow]];
    [hud release];
    
    __block id succeededObserver = nil;
    [[NSNotificationCenter defaultCenter] addObserverForName:kInstapaperRequestSucceededNotification object:request queue:nil usingBlock:^(NSNotification *notification) {
        [hud setText:@"Saved!"];
        [hud setState:kProgressHUDStateCompleted];
        [hud dismissAfterDelay:0.8f animated:YES];
        
        [[NSNotificationCenter defaultCenter] removeObserver:succeededObserver];
    }];
    
    __block id failedObserver = nil;
    failedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kInstapaperRequestFailedNotification object:request queue:nil usingBlock:^(NSNotification *notification) {
        [hud setText:@"Error Saving"];
        [hud setState:kProgressHUDStateError];
        [hud dismissAfterDelay:0.8f animated:YES];
        
        [[NSNotificationCenter defaultCenter] removeObserver:failedObserver];
    }];
    
    [request addItemWithURL:url];
    [request autorelease];
}

- (void)loginControllerDidLogin:(InstapaperLoginController *)controller {
    [controller dismissModalViewControllerAnimated:YES];
    [self submitInstapaperRequestForURL:[controller pendingURL]];
}

- (void)loginControllerDidCancel:(InstapaperLoginController *)controller {
    [controller dismissModalViewControllerAnimated:YES];
}

- (void)submitURL:(NSURL *)url fromController:(UIViewController *)controller {
    if ([InstapaperSession currentSession] != nil) {
        [self submitInstapaperRequestForURL:url];
    } else {
        InstapaperLoginController *login = [[InstapaperLoginController alloc] init];
        [login setPendingURL:url];
        [login setDelegate:self];
                
        NavigationController *navigation = [[NavigationController alloc] initWithRootViewController:login];
        [controller presentModalViewController:[navigation autorelease] animated:YES];
    }
}


@end
