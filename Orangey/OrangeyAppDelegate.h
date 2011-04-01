//
//  OrangeyAppDelegate.h
//  Orangey
//
//  Created by Grant Paul on 3/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatusDelegate.h"

@class NavigationController;
@interface OrangeyAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, StatusDelegate> {
    UIWindow *window;
    NavigationController *navigationController;
}

@end
