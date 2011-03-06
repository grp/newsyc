//
//  ProfileController.h
//  Orangey
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadingController.h"

@class ProfileHeaderView;
@interface ProfileController : LoadingController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate> {
    UITableView *tableView;
    ProfileHeaderView *header;
}

@end
