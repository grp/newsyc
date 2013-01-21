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
#import "PingController.h"

@interface AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate, UISplitViewControllerDelegate, PingControllerDelegate> {
    UIWindow *window;
    
    SplitViewController *splitController;
    
    NavigationController *navigationController;
    NavigationController *rightNavigationController;
    
    UIPopoverController *popover;
    UIBarButtonItem *popoverItem;
    
    PingController *pingController;
}

- (void)pushBranchViewController:(UIViewController *)branchController animated:(BOOL)animated;
- (void)pushLeafViewController:(UIViewController *)leafController animated:(BOOL)animated;

- (BOOL)leafContainsViewController:(UIViewController *)leafController;
- (void)setLeafViewController:(UIViewController *)leafController animated:(BOOL)animated;
- (void)clearLeafViewControllerAnimated:(BOOL)animated;

- (void)popBranchToViewController:(UIViewController *)branchController animated:(BOOL)animated;
- (void)popLeafToViewController:(UIViewController *)leafController animated:(BOOL)animated;

@end

@interface UINavigationController (AppDelegate)

- (void)pushController:(UIViewController *)controller animated:(BOOL)animated;
- (void)popToController:(UIViewController *)controller animated:(BOOL)animated;

@end
