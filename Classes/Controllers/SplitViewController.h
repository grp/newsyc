//
//  SplitViewController.h
//  newsyc
//
//  Created by Grant Paul on 3/21/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

@class NavigationController;

@interface SplitViewController : UISplitViewController <UISplitViewControllerDelegate, UINavigationControllerDelegate> {
    NavigationController *navigationController;
    NavigationController *rightNavigationController;

    UIPopoverController *popover;
    UIBarButtonItem *popoverItem;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController;

- (void)pushBranchViewController:(UIViewController *)branchController animated:(BOOL)animated;
- (void)pushLeafViewController:(UIViewController *)leafController animated:(BOOL)animated;

- (BOOL)leafContainsViewController:(UIViewController *)leafController;
- (void)setLeafViewController:(UIViewController *)leafController animated:(BOOL)animated;
- (void)clearLeafViewControllerAnimated:(BOOL)animated;

- (void)popBranchToViewController:(UIViewController *)branchController animated:(BOOL)animated;
- (void)popLeafToViewController:(UIViewController *)leafController animated:(BOOL)animated;

- (void)pushController:(UIViewController *)controller animated:(BOOL)animated;
- (void)popToController:(UIViewController *)controller animated:(BOOL)animated;

@end

@interface UISplitViewController (Convenience)

- (void)pushController:(UIViewController *)controller animated:(BOOL)animated;
- (void)popToController:(UIViewController *)controller animated:(BOOL)animated;

@end
