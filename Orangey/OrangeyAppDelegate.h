//
//  OrangeyAppDelegate.h
//  Orangey
//
//  Created by Grant Paul on 3/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatusDelegate.h"

@interface OrangeyAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, StatusDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
    NSArray *sessions;
}

@end
