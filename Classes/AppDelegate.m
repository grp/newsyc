//
//  AppDelegate.m
//  newsyc
//
//  Created by Grant Paul on 3/3/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "SplitViewController.h"
#import "NavigationController.h"
#import "SessionListController.h"

#import "BrowserController.h"

#import "HNKit.h"
#import "InstapaperSession.h"

@implementation AppDelegate

#pragma mark - Application Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    HNSessionController *sessionController = [HNSessionController sessionController];
    NSArray *sessions = [sessionController sessions];
    HNSession *recentSession = [sessionController recentSession];

    if (recentSession == nil && [sessions count] == 1) {
        recentSession = [sessions lastObject];
    }

    SessionListController *sessionListController = [[SessionListController alloc] init];
    [sessionListController setAutomaticDisplaySession:recentSession];
    [sessionListController autorelease];
        
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        navigationController = [[NavigationController alloc] initWithRootViewController:sessionListController];
        [window setRootViewController:navigationController];

        [HNObjectBodyRenderer setDefaultFontSize:13.0f];
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        splitController = [[SplitViewController alloc] initWithRootViewController:sessionListController];        
        [window setRootViewController:splitController];

        [HNObjectBodyRenderer setDefaultFontSize:16.0f];
    } else {
        NSAssert(NO, @"Invalid Device Type");
    }

    [sessionController refresh];

    [InstapaperSession logoutIfNecessary];

    pingController = [[PingController alloc] init];
    [pingController setDelegate:self];
    [pingController ping];
                  
    [window makeKeyAndVisible];
        
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[HNSessionController sessionController] refresh];

    [InstapaperSession logoutIfNecessary];
}

- (void)dealloc {
    [window release];
    [navigationController release];
    [splitController release];
    [pingController release];

    [super dealloc];
}

#pragma mark - Ping Controller

- (void)pingController:(PingController *)ping completedAcceptingURL:(NSURL *)url {
    BrowserController *browserController = [[BrowserController alloc] initWithURL:url];
    if (navigationController != nil) {
        [navigationController pushController:browserController animated:YES];
    } else if (splitController != nil) {
        [splitController pushController:browserController animated:YES];
    }
    [browserController release];

    [pingController release];
    pingController = nil;
}

- (void)pingController:(PingController *)ping failedWithError:(NSError *)error {
    [pingController release];
    pingController = nil;
}

- (void)pingControllerCompletedWithoutAction:(PingController *)ping {
    [pingController release];
    pingController = nil;
}

@end
