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
#import "MainTabBarController.h"

#import "SubmissionListController.h"
#import "SearchController.h"
#import "SessionProfileController.h"
#import "BrowserController.h"
#import "MoreController.h"

#import "HNKit.h"
#import "InstapaperSession.h"
#import "JSON.h"

#import "UINavigationItem+MultipleItems.h"

@interface AppDelegate ()
- (void)startConnection;
@end

@implementation UINavigationController (AppDelegate)

- (BOOL)controllerBelongsOnLeft:(UIViewController *)controller {
    return [controller isKindOfClass:[MainTabBarController class]]
        || [controller isKindOfClass:[SearchController class]]
        || [controller isKindOfClass:[ProfileController class]]
        || [controller isKindOfClass:[MoreController class]]
        || [controller isKindOfClass:[SubmissionListController class]];
}

- (void)pushController:(UIViewController *)controller animated:(BOOL)animated {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if ([self presentingViewController] == nil) {
            if ([self controllerBelongsOnLeft:controller]) {
                [delegate pushBranchViewController:controller animated:animated];
            } else if ([self controllerBelongsOnLeft:[self topViewController]]) {
                [delegate setLeafViewController:controller];
            } else {
                [delegate pushLeafViewController:controller animated:animated];
            }
        } else {
            if (![self controllerBelongsOnLeft:controller]) {
                if ([[self presentingViewController] presentingViewController] != nil && [[self presentingViewController] isKindOfClass:[UINavigationController class]]) {
                    // If we are a double-stacked modal controller, push on the bottom controller.
                    UINavigationController *presenting = (UINavigationController *) [self presentingViewController];
                    [presenting pushViewController:controller animated:animated];
                } else {
                    [delegate pushLeafViewController:controller animated:animated];
                }
                
                [self dismissModalViewControllerAnimated:animated];
            } else {
                [self pushViewController:controller animated:animated];
            }
        }
    } else {
        [delegate pushBranchViewController:controller animated:animated];
    }
}

@end

@implementation AppDelegate

- (NSString *)version {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    MainTabBarController *mainTabBarController = [[MainTabBarController alloc] init];
    [mainTabBarController setTitle:@"Hacker News"];
    [mainTabBarController autorelease];
    
    navigationController = [[NavigationController alloc] initWithRootViewController:mainTabBarController];
    [navigationController autorelease];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [window setRootViewController:navigationController];
        
        [HNEntryBodyRenderer setDefaultFontSize:13.0f];
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        emptyController = [[EmptyController alloc] init];
        [emptyController autorelease];
        
        rightNavigationController = [[NavigationController alloc] initWithRootViewController:emptyController];
        [rightNavigationController setDelegate:self];
        [rightNavigationController autorelease];
        
        splitController = [[SplitViewController alloc] init];
        [splitController setViewControllers:[NSArray arrayWithObjects:navigationController, rightNavigationController, nil]];
        if ([splitController respondsToSelector:@selector(setPresentsWithGesture:)]) [splitController setPresentsWithGesture:YES];
        [splitController setDelegate:self];
        [splitController autorelease];
        
        [window setRootViewController:splitController];
        
        [HNEntryBodyRenderer setDefaultFontSize:14.0f];
    } else {
        NSLog(@"Error: what kind of device is this?");
    }
    
    if (![[HNSession currentSession] isAnonymous]) {
        [[HNSession currentSession] reloadToken];
    }
    
    [InstapaperSession logoutIfNecessary];
                  
    [window makeKeyAndVisible];
    [self startConnection];
        
    return YES;
}
         
#pragma mark - View Controllers
         
- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    popoverItem = [barButtonItem retain];
    // XXX: work around navigation bar shrinking this button
    [popoverItem setTitle:@"HN"];
    popover = [pc retain];
    
    NSArray *controllers = [rightNavigationController viewControllers];
    if ([controllers count] > 0) {
        UIViewController *root = [controllers objectAtIndex:0];
        [[root navigationItem] addLeftBarButtonItem:popoverItem atPosition:UINavigationItemPositionLeft];
    }
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button {
    NSArray *controllers = [rightNavigationController viewControllers];
    if ([controllers count] > 0) {
        UIViewController *root = [controllers objectAtIndex:0];
        [[root navigationItem] removeLeftBarButtonItem:popoverItem];
    }
    
    [popoverItem release];
    popoverItem = nil;
    [popover release];
    popover = nil;
}

- (void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)viewController {
    // XXX: workaround Apple bug causing the controller to stretch to fill
    // the entire screen after it unloads the view from a memory warning
    CGRect frame = [[viewController view] frame];
    frame.size.width = 320.0f;
    [[viewController view] setFrame:frame];
}

- (void)pushBranchViewController:(UIViewController *)branchController animated:(BOOL)animated {
    [navigationController pushViewController:branchController animated:animated];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [[branchController navigationItem] setRightBarButtonItems:[[branchController navigationItem] leftBarButtonItems]];
        [[branchController navigationItem] setLeftBarButtonItems:nil];
    }
}

- (void)pushLeafViewController:(UIViewController *)leafController animated:(BOOL)animated {
    [rightNavigationController pushViewController:leafController animated:animated];
}

- (void)setLeafViewController:(UIViewController *)leafController {
    [rightNavigationController setViewControllers:[NSArray arrayWithObject:leafController]];
    
    if (popoverItem != nil) [[leafController navigationItem] addLeftBarButtonItem:popoverItem atPosition:UINavigationItemPositionLeft];
    if (popover != nil) [popover dismissPopoverAnimated:YES];
}

#pragma mark - Startup Connection

- (void)startConnection {
    NSString *appv = [self version];
    NSString *sysv = [[UIDevice currentDevice] systemVersion];
    NSString *dev = [[UIDevice currentDevice] model];
    NSString *from = [[NSUserDefaults standardUserDefaults] objectForKey:@"current-version"] ?: @"";
    BOOL seen = [[NSUserDefaults standardUserDefaults] boolForKey:@"initial-install-seen"];
    
    received = [[NSMutableData alloc] init];
    
    NSString *url = [NSString stringWithFormat:@"http://newsyc.me/ping?appv=%@&sysv=%@&dev=%@&seen=%d&oldv=%@", [appv stringByURLEncodingString], [sysv stringByURLEncodingString], [dev stringByURLEncodingString], seen, [from stringByURLEncodingString]];
    NSURL *requestURL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
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
        NSString *moreButton = [representation objectForKey:@"more-button"];
        NSString *moreURL = [representation objectForKey:@"more-url"];
        
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
            [alert setDelegate:self];
            [alert setTitle:title];
            [alert setMessage:message];
            if (!locked) {
                [alert addButtonWithTitle:button];
                
                if (moreButton != nil && moreURL != nil) {
                    [alert addButtonWithTitle:moreButton];
                    
                    moreInfoURL = [[NSURL URLWithString:moreURL] retain];
                }
            }
            [alert show];
            [alert release];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[self version] forKey:@"current-version"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"initial-install-seen"];
    
    [received release];
    received = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {    
        BrowserController *browser = [[BrowserController alloc] initWithURL:moreInfoURL];
        [navigationController pushController:browser animated:YES];
        [browser release];
    }
    
    [moreInfoURL release];
    moreInfoURL = nil;
}

#pragma mark - Application Lifecycle

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
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {

}

- (void)dealloc {
    [window release];
    [navigationController release];
    [rightNavigationController release];
    [splitController release];

    [super dealloc];
}

@end
