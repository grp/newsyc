//
//  EntryListController.h
//  newsyc
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadingController.h"

@interface EntryListController : LoadingController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *tableView;
}

@end
