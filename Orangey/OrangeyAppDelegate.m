//
//  OrangeyAppDelegate.m
//  Orangey
//
//  Created by Grant Paul on 3/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OrangeyAppDelegate.h"
#import "SubmissionListController.h"
#import "ProfileController.h"

#import "HNKit.h"

@implementation OrangeyAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    tabBarController = [[UITabBarController alloc] init];
    [window setRootViewController:tabBarController];
    
    SubmissionListController *home = [[[SubmissionListController alloc] initWithSource:[[[HNEntryList alloc] initWithIdentifier:kHNEntryListTypeNews] autorelease]] autorelease];
    [home setTitle:@"Hacker News"];
    [home setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"Home" image:[UIImage imageNamed:@"home.png"] tag:0] autorelease]];
    
    SubmissionListController *new = [[[SubmissionListController alloc] initWithSource:[[[HNEntryList alloc] initWithIdentifier:kHNEntryListTypeNew] autorelease]] autorelease];
    [new setTitle:@"New Submissions"];
    [new setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"New" image:[UIImage imageNamed:@"new.png"] tag:0] autorelease]];
    
    ProfileController *profile = [[[ProfileController alloc] initWithSource:[[[HNUser alloc] initWithIdentifier:@"daeken"] autorelease]] autorelease];
    [profile setTitle:@"Profile"];
    [profile setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"Profile" image:[UIImage imageNamed:@"profile.png"] tag:0] autorelease]];
    
    UIViewController *more = [[[UIViewController alloc] init] autorelease];
    [more setTitle:@"More"];
    [more setTabBarItem:[[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:0] autorelease]];
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:home, new, profile, more, nil];
    for (int i = 0; i < [items count]; i++) {
        UIViewController *item = [items objectAtIndex:i];
        UINavigationController *navigation = [[[UINavigationController alloc] initWithRootViewController:item] autorelease];
        [[navigation navigationBar] setTintColor:[UIColor colorWithRed:0.9f green:0.3 blue:0.0f alpha:1.0f]];
        [items replaceObjectAtIndex:i withObject:navigation];
    }
    [tabBarController setViewControllers:items];
    
    [window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {

}

- (void)dealloc {
    [window release];
    [tabBarController release];

    [super dealloc];
}

@end
