//
//  NavigationController.h
//  newsyc
//
//  Created by Grant Paul on 3/29/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

// An orange navigation controller. Sometimes.

#import "LoginController.h"
#import "HackerNewsLoginController.h"

@protocol NavigationControllerLoginDelegate;

@interface NavigationController : UINavigationController <LoginControllerDelegate> {
    id<NavigationControllerLoginDelegate> __weak loginDelegate;
}

@property (nonatomic, weak) id<NavigationControllerLoginDelegate> loginDelegate;
- (void)requestLogin;
- (void)requestSessions;

@end

@interface UIViewController (NavigationController)

- (NavigationController *)navigation;

@end

@protocol NavigationControllerLoginDelegate <NSObject>

- (void)navigationController:(NavigationController *)navigationController didLoginWithSession:(HNSession *)session;
- (void)navigationControllerRequestedSessions:(NavigationController *)navigationController;

@end
