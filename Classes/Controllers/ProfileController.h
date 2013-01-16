//
//  ProfileController.h
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "LoadingController.h"
#import "OrangeTableView.h"
#import "BodyTextView.h"

@class ProfileHeaderView;
@interface ProfileController : LoadingController <UITableViewDelegate, UITableViewDataSource, BodyTextViewDelegate> {
    OrangeTableView *tableView;
    ProfileHeaderView *header;
}

@end
