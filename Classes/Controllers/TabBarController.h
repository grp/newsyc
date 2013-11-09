//
//  TabBarController.h
//  newsyc
//
//  Created by Grant Paul on 10/7/13.
//
//

@interface TabBarController : UIViewController <UITabBarDelegate> {
    UITabBar *tabBar;
    NSArray *viewControllers;
    UIViewController *selectedViewController;
}

@property (nonatomic, readonly) UITabBar *tabBar;

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, assign) UIViewController *selectedViewController;

@end
