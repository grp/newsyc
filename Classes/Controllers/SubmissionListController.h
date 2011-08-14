//
//  SubmissionList.h
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "EntryListController.h"

#import "PullToRefreshView.h"

@interface SubmissionListController : EntryListController <PullToRefreshViewDelegate> {
    PullToRefreshView *pullToRefreshView;
}

@end
