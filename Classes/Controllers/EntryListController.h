//
//  EntryListController.h
//  newsyc
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "LoadingController.h"
#import "PullToRefreshView.h"

@interface EntryListController : LoadingController <UITableViewDelegate, UITableViewDataSource, PullToRefreshViewDelegate> {
    UITableView *tableView;
    UILabel *emptyLabel;
    
    LoadingIndicatorView *moreLoadingIndicator;
    PullToRefreshView *pullToRefreshView;
    
    NSArray *entries;
}

- (HNEntry *)entryAtIndexPath:(NSIndexPath *)indexPath;
- (void)configureCell:(UITableViewCell *)cell forEntry:(HNEntry *)entry;

@end
