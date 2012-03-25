//
//  MainTabBarController.h
//  newsyc
//
//  Created by Grant Paul on 3/30/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "BarButtonItem.h"

#import "LoginController.h"

@class EntryListController, SessionProfileController, MoreController, SearchController;

@interface MainTabBarController : UITabBarController <UIActionSheetDelegate, LoginControllerDelegate, UITabBarControllerDelegate> {
    EntryListController *home;
    EntryListController *latest;
	SearchController *search;
    SessionProfileController *profile;
    MoreController *more;
    
    NSDate *lastSeen;
    BarButtonItem *composeItem;
    
    void (^loginCompletionBlock)(void);
}

@end
