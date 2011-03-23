//
//  OrangeyAppDelegate.m
//  Orangey
//
//  Created by Grant Paul on 3/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OrangeyAppDelegate.h"
#import "InstapaperAPI.h"
#import "SubmissionListController.h"
#import "CommentListController.h"
#import "ProfileController.h"
#import "MoreController.h"
#import "LoginController.h"

#import "HNKit.h"

#define kNavigationTintOrange [UIColor colorWithRed:0.9f green:0.3 blue:0.0f alpha:1.0f]

@implementation OrangeyAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [[InstapaperAPI sharedInstance] setDelegate:self];
    [[InstapaperAPI sharedInstance] setUsername:[defaults objectForKey:@"instapaper-username"]];
    [[InstapaperAPI sharedInstance] setPassword:[defaults objectForKey:@"instapaper-password"]];
    
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    tabBarController = [[UITabBarController alloc] init];
    [window setRootViewController:tabBarController];
    
    HNEntry *homeEntry = [[[HNEntry alloc] initWithType:kHNPageTypeSubmissions] autorelease];
    SubmissionListController *home = [[[SubmissionListController alloc] initWithSource:homeEntry] autorelease];
    [home setTitle:@"Hacker News"];
    [home setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"Home" image:[UIImage imageNamed:@"home.png"] tag:0] autorelease]];
    
    HNEntry *newEntry = [[[HNEntry alloc] initWithType:kHNPageTypeNewSubmissions] autorelease];
    SubmissionListController *new = [[[SubmissionListController alloc] initWithSource:newEntry] autorelease];
    [new setTitle:@"New Submissions"];
    [new setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"New" image:[UIImage imageNamed:@"new.png"] tag:0] autorelease]];
    
    HNEntry *profileEntry = [[[HNUser alloc] initWithIdentifier:@"Xuzz"] autorelease];
    ProfileController *profile = [[[ProfileController alloc] initWithSource:profileEntry] autorelease];
    [profile setTitle:@"Profile"];
    [profile setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"Profile" image:[UIImage imageNamed:@"profile.png"] tag:0] autorelease]];
    
    MoreController *more = [[MoreController alloc] init];
    [more setTitle:@"More"];
    [more setTabBarItem:[[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:0] autorelease]];
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:home, new, profile, more, nil];
    for (int i = 0; i < [items count]; i++) {
        UIViewController *item = [items objectAtIndex:i];
        UINavigationController *navigation = [[[UINavigationController alloc] initWithRootViewController:item] autorelease];
        [[navigation navigationBar] setTintColor:kNavigationTintOrange];
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
    [tabBarController release];

    [super dealloc];
}

@end
