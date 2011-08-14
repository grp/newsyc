//
//  MainTabBarController.h
//  newsyc
//
//  Created by Grant Paul on 3/30/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "LoginController.h"

@class SubmissionListController, SessionProfileController, MoreController, SearchController;

@interface MainTabBarController : UITabBarController <UIActionSheetDelegate, LoginControllerDelegate, UITabBarControllerDelegate> {
    SubmissionListController *home;
    SubmissionListController *latest;
	SearchController *search;
    SessionProfileController *profile;
    MoreController *more;
    
    NSDate *lastSeen;
    UIBarButtonItem *composeItem;
    
    void (^loginCompletionBlock)(void);
}

@end
