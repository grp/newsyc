//
//  AppDelegate.h
//  newsyc
//
//  Created by Grant Paul on 3/3/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "LoginController.h"
#import "SplitViewController.h"
#import "NavigationController.h"
#import "EmptyController.h"

@interface AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate, UISplitViewControllerDelegate, UIAlertViewDelegate> {
    UIWindow *window;
    
    SplitViewController *splitController;
    EmptyController *emptyController;
    
    NavigationController *navigationController;
    NavigationController *rightNavigationController;
    
    UIPopoverController *popover;
    UIBarButtonItem *popoverItem;
    
    NSMutableData *received;
    NSURL *moreInfoURL;
}

- (void)pushBranchViewController:(UIViewController *)branchController animated:(BOOL)animated;
- (void)pushLeafViewController:(UIViewController *)leafController animated:(BOOL)animated;
- (void)setLeafViewController:(UIViewController *)leafController;

@end

@interface UINavigationController (AppDelegate)

- (void)pushController:(UIViewController *)controller animated:(BOOL)animated;

@end
