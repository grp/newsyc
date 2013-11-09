//
//  TabBarController.m
//  newsyc
//
//  Created by Grant Paul on 10/7/13.
//
//

#import "TabBarController.h"

@implementation TabBarController
@synthesize tabBar, viewControllers, selectedViewController;

- (void)loadView {
    [super loadView];

    tabBar = [[UITabBar alloc] init];
    [tabBar setDelegate:self];
    [[self view] addSubview:tabBar];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [tabBar sizeToFit];
    [tabBar setFrame:CGRectMake(0, [[self view] bounds].size.height - [tabBar bounds].size.height, [[self view] bounds].size.width, [tabBar bounds].size.height)];

    CGRect controllerFrame = CGRectMake(0, [[self topLayoutGuide] length], [[self view] bounds].size.width, [[self view] bounds].size.height - [[self topLayoutGuide] length] - [[self bottomLayoutGuide] length] - [tabBar bounds].size.height);
    [[selectedViewController view] setFrame:controllerFrame];
}

- (void)setViewControllers:(NSArray *)viewControllers_ {
    if (viewControllers != viewControllers_) {
        [self setSelectedViewController:nil];

        for (UIViewController *viewController in viewControllers) {
            [viewController willMoveToParentViewController:nil];
            [viewController removeFromParentViewController];
        }

        [viewControllers release];
        viewControllers = [viewControllers_ copy];

        NSMutableArray *tabBarItems = [NSMutableArray array];

        for (UIViewController *viewController in viewControllers) {
            [self addChildViewController:viewController];
            [viewController didMoveToParentViewController:self];

            [tabBarItems addObject:[viewController tabBarItem]];
        }

        [self view];
        [tabBar setItems:tabBarItems];

        if ([viewControllers count] > 0) {
            [self setSelectedViewController:[viewControllers objectAtIndex:0]];
        }
    }
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController_ {
    if (selectedViewController != selectedViewController_) {
        [[selectedViewController view] removeFromSuperview];

        selectedViewController = selectedViewController_;
        [tabBar setSelectedItem:[selectedViewController tabBarItem]];

        [[self view] addSubview:[selectedViewController view]];
        [[self view] bringSubviewToFront:tabBar];
    }
}

- (void)tabBar:(UITabBar *)tabBar_ didSelectItem:(UITabBarItem *)item {
    NSInteger index = [[tabBar items] indexOfObject:item];
    [self setSelectedViewController:[viewControllers objectAtIndex:index]];
}

@end
