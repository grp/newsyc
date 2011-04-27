//
//  AppDelegate.m
//  newsyc
//
//  Created by Grant Paul on 3/3/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "NavigationController.h"
#import "MainTabBarController.h"

#import "HNKit.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    navigationController = [[NavigationController alloc] init];
    [window setRootViewController:navigationController];
    
    MainTabBarController *mainTabBarController = [[MainTabBarController alloc] init];
    [mainTabBarController setTitle:@"Hacker News"];
    [navigationController setViewControllers:[NSArray arrayWithObjects:mainTabBarController, nil]];
    [mainTabBarController release];
    
    if (![[HNSession currentSession] isAnonymous]) {
        [[HNSession currentSession] reloadToken];
    }
                  
    [window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (![[HNSession currentSession] isAnonymous]) {
        [[HNSession currentSession] reloadToken];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {

}

- (void)dealloc {
    [window release];
    [navigationController release];

    [super dealloc];
}

@end
