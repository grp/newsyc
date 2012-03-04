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
#import "InstapaperSession.h"
#import "JSON.h"

@implementation AppDelegate

- (NSString *)version {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    MainTabBarController *mainTabBarController = [[MainTabBarController alloc] init];
    navigationController = [[NavigationController alloc] initWithRootViewController:[mainTabBarController autorelease]];
    [window setRootViewController:[navigationController autorelease]];
    [mainTabBarController setTitle:@"Hacker News"];
    
    if (![[HNSession currentSession] isAnonymous]) {
        [[HNSession currentSession] reloadToken];
    }
    
    [InstapaperSession logoutIfNecessary];
                  
    [window makeKeyAndVisible];
    
    NSString *appv = [self version];
    NSString *sysv = [[UIDevice currentDevice] systemVersion];
    NSString *dev = [[UIDevice currentDevice] model];
    NSString *udid = [[UIDevice currentDevice] uniqueIdentifier];
    NSString *from = [[NSUserDefaults standardUserDefaults] objectForKey:@"current-version"] ?: @"";
    BOOL seen = [[NSUserDefaults standardUserDefaults] boolForKey:@"initial-install-seen"];
    
    received = [[NSMutableData alloc] init];
    
    NSString *url = [NSString stringWithFormat:@"http://newsyc.me/ping?appv=%@&sysv=%@&dev=%@&udid=%@&seen=%d&oldv=%@", [appv stringByURLEncodingString], [sysv stringByURLEncodingString], [dev stringByURLEncodingString], [udid stringByURLEncodingString], seen, [from stringByURLEncodingString]];
    NSURL *requestURL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
    
    return YES;
}
- (void)connection:(NSURLConnection *)connection_ didReceiveData:(NSData *)data {
    [received appendData:data];
}

- (void)connection:(NSURLConnection *)connection_ didFailWithError:(NSError *)error {
    [received release];
    received = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *json = [[[NSString alloc] initWithData:received encoding:NSUTF8StringEncoding] autorelease];
    id representation = [[[[SBJsonParser alloc] init] autorelease] objectWithString:json];
    
    if ([representation isKindOfClass:[NSDictionary class]]) {
        NSString *message = [representation objectForKey:@"message"];
        NSString *title = [representation objectForKey:@"title"];
        NSString *button = [representation objectForKey:@"button"];
        
        BOOL locked = [[representation objectForKey:@"locked"] boolValue];
        
        if (locked) {
            UIWindow *lockedWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            [lockedWindow setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            [lockedWindow setBackgroundColor:[UIColor darkGrayColor]];
            [window setHidden:YES];
            [lockedWindow makeKeyAndVisible];
        }
        
        if (title != nil) {
            if (button == nil) button = @"Continue";
            
            UIAlertView *alert = [[UIAlertView alloc] init];
            [alert setTitle:title];
            [alert setMessage:message];
            if (!locked) [alert addButtonWithTitle:button];
            [alert show];
            [alert release];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[self version] forKey:@"current-version"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"initial-install-seen"];
    
    [received release];
    received = nil;
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (![[HNSession currentSession] isAnonymous]) {
        [[HNSession currentSession] reloadToken];
    }
    
    [InstapaperSession logoutIfNecessary];
    
    // to apply any necessary color changes
    [navigationController viewWillAppear:NO];
    [navigationController viewDidAppear:NO];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {

}

- (void)dealloc {
    [window release];
    [navigationController release];

    [super dealloc];
}

@end
