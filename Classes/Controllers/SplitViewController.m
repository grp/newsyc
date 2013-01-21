//
//  SplitViewController.m
//  newsyc
//
//  Created by Grant Paul on 3/21/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "UINavigationItem+MultipleItems.h"

#import "NavigationController.h"
#import "EmptyController.h"
#import "SplitViewController.h"

@implementation SplitViewController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    if ((self = [super init])) {
        [self setDelegate:self];
        
        if ([self respondsToSelector:@selector(setPresentsWithGesture:)]) {
            [self setPresentsWithGesture:YES];
        }

        navigationController = [[NavigationController alloc] initWithRootViewController:rootViewController];
        rightNavigationController = [[NavigationController alloc] init];
        [self setViewControllers:[NSArray arrayWithObjects:navigationController, rightNavigationController, nil]];

        [self clearLeafViewControllerAnimated:NO];
    }

    return self;
}

- (void)dealloc {
    [navigationController release];
    [rightNavigationController release];

    [super dealloc];
}

#pragma mark - Split

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

#pragma mark - Navigation

- (void)pushController:(UIViewController *)controller animated:(BOOL)animated {
    [navigationController pushController:controller animated:animated];
}

- (void)popToController:(UIViewController *)controller animated:(BOOL)animated {
    [navigationController popToController:controller animated:animated];
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

- (BOOL)leafContainsViewController:(UIViewController *)leafController {
    return [[rightNavigationController viewControllers] containsObject:leafController];
}

- (void)setLeafViewController:(UIViewController *)leafController animated:(BOOL)animated {
    [rightNavigationController setViewControllers:[NSArray arrayWithObject:leafController]];

    if (popoverItem != nil) [[leafController navigationItem] addLeftBarButtonItem:popoverItem atPosition:UINavigationItemPositionLeft];
    if (popover != nil) [popover dismissPopoverAnimated:animated];
}

- (void)clearLeafViewControllerAnimated:(BOOL)animated {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        EmptyController *emptyController = [[EmptyController alloc] init];
        if (popoverItem != nil) [[emptyController navigationItem] addLeftBarButtonItem:popoverItem atPosition:UINavigationItemPositionLeft];
        [rightNavigationController setViewControllers:[NSArray arrayWithObject:emptyController]];
        [emptyController release];
    }
}

- (void)popBranchToViewController:(UIViewController *)branchController animated:(BOOL)animated {
    [navigationController popToViewController:branchController animated:animated];
}

- (void)popLeafToViewController:(UIViewController *)leafController animated:(BOOL)animated {
    [rightNavigationController popToViewController:leafController animated:animated];
}

AUTOROTATION_FOR_PAD_ONLY;

@end
