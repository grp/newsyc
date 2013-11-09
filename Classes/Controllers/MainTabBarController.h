//
//  MainTabBarController.h
//  newsyc
//
//  Created by Grant Paul on 3/30/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "BarButtonItem.h"

#import "LoginController.h"
#import "TabBarController.h"

@class EntryListController, SessionProfileController, MoreController, SearchController, HNSession;

@interface MainTabBarController : UITabBarController <UIActionSheetDelegate, UITabBarControllerDelegate> {
    HNSession *session;

    EntryListController *home;
    EntryListController *latest;
	SearchController *search;
    SessionProfileController *profile;
    MoreController *more;
    
    BarButtonItem *composeItem;
}

- (id)initWithSession:(HNSession *)session_;

@end
