//
//  AppDelegate.m
//  newsyc
//
//  Created by Grant Paul on 3/3/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "InstapaperAPI.h"
#import "NavigationController.h"
#import "MainTabBarController.h"
#import "InstapaperLoginController.h"

#import "HNKit.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [[InstapaperAPI sharedInstance] setDelegate:self];
    [[InstapaperAPI sharedInstance] setUsername:[defaults objectForKey:@"instapaper-username"]];
    [[InstapaperAPI sharedInstance] setPassword:[defaults objectForKey:@"instapaper-password"]];
    
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    navigationController = [[NavigationController alloc] init];
    [window setRootViewController:navigationController];
    
    MainTabBarController *mainTabBarController = [[MainTabBarController alloc] init];
    [mainTabBarController setTitle:@"Hacker News"];
    [navigationController setViewControllers:[NSArray arrayWithObjects:mainTabBarController, nil]];
    
    [window makeKeyAndVisible];
    firstModal = YES;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[InstapaperAPI sharedInstance] setUsername:[defaults objectForKey:@"instapaper-username"]];
    [[InstapaperAPI sharedInstance] setPassword:[defaults objectForKey:@"instapaper-password"]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {

}

- (void)handleStatusEventWithType:(StatusDelegateType)type message:(NSString *)message {
    [navigationController dismissModalViewControllerAnimated:YES];
    if (type == kStatusDelegateTypeNotice) {
        NSLog(@"Notice: %@", message);
    } else if (type == kStatusDelegateTypeWarning) {
        // XXX: display unobtrusive notification
    } else if (type == kStatusDelegateTypeError) {
        if([message isEqualToString:@"Instapaper encountered an internal error. Please try again later."]) {
            UIAlertView *alert = [[UIAlertView alloc]
                initWithTitle:@"Error"
                message:message
                delegate:self
                cancelButtonTitle:nil
                otherButtonTitles:@"Continue", nil
            ];
            
            [[alert autorelease] show];
        }
        else {
            NSLog(@"%@", message);
            InstapaperLoginController *instapaperLogin = [[InstapaperLoginController alloc] initWithMessage:message];
            [instapaperLogin setDelegate:self];
            UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:instapaperLogin];

            if(!firstModal) {
                [navigationController setToShow:navigation];
                [navigationController setNeedToShow:YES];
                NSLog(@"%@", @"need to show set to yes");
                firstModal = NO;
            } else {
                [navigationController presentModalViewController:navigation animated:YES];
                firstModal = NO;
            }
        }
    } else {
        // XXX: that was bad. do something about it.
    }
}

- (void)dealloc {
    [window release];
    [navigationController release];

    [super dealloc];
}

- (void)loginControllerDidLogin:(LoginController *)controller {
    [[InstapaperAPI sharedInstance] addItemWithURL:[[InstapaperAPI sharedInstance] lastURL]];
}

- (void)loginControllerDidCancel:(LoginController *)controller {
    [navigationController dismissModalViewControllerAnimated:YES];
}

@end
