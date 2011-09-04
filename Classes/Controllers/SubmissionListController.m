//
//  SubmissionList.m
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"

#import "SubmissionListController.h"
#import "SubmissionTableCell.h"
#import "LoadingTableCell.h"
#import "CommentListController.h"

@implementation SubmissionListController

- (void)removeStatusView:(UIView *)view {
    [super removeStatusView:view];
    
    // XXX: this is a hack :(
    if (view == indicator) {
        [tableView setScrollEnabled:YES];
    }
}

- (void)addStatusView:(UIView *)view resize:(BOOL)resize {
    [super addStatusView:view resize:resize];
    
    // XXX: this is a hack :(
    if (view == indicator) {
        //[tableView setContentOffset:CGPointZero];
        [tableView setScrollEnabled:NO];
    }
}

AUTOROTATION_FOR_PAD_ONLY

@end
