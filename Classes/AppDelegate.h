//
//  AppDelegate.h
//  newsyc
//
//  Created by Grant Paul on 3/3/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "LoginController.h"

@class NavigationController;
@interface AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, NSURLConnectionDelegate> {
    UIWindow *window;
    NavigationController *navigationController;
    
    NSMutableData *received;
}

@end
