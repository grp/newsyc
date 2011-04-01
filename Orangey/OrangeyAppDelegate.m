//
//  OrangeyAppDelegate.m
//  Orangey
//
//  Created by Grant Paul on 3/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OrangeyAppDelegate.h"
#import "InstapaperAPI.h"
#import "NavigationController.h"
#import "MainTabBarController.h"

#import "HNKit.h"


@implementation OrangeyAppDelegate

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
    if (type == kStatusDelegateTypeNotice) {
        NSLog(@"Notice: %@", message);
    } else if (type == kStatusDelegateTypeWarning) {
        // XXX: display unobtrusive notification
    } else if (type == kStatusDelegateTypeError) {
        UIAlertView *alert = [[UIAlertView alloc]
            initWithTitle:@"Error"
            message:message
            delegate:self
            cancelButtonTitle:nil
            otherButtonTitles:@"Continue", nil
        ];
        
        [[alert autorelease] show];
    } else {
        // XXX: that was bad. do something about it.
    }
}

- (void)dealloc {
    [window release];
    [navigationController release];

    [super dealloc];
}

@end
