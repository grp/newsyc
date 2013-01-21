//
//  AppDelegate.h
//  newsyc
//
//  Created by Grant Paul on 3/3/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "SplitViewController.h"
#import "NavigationController.h"
#import "PingController.h"

@interface AppDelegate : NSObject <UIApplicationDelegate, PingControllerDelegate> {
    UIWindow *window;

    PingController *pingController;
    
    SplitViewController *splitController;
    NavigationController *navigationController;
}

@end
