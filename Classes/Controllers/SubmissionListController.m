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

- (void)dealloc {
    [refreshView release];
    [super dealloc];
}

- (void)loadView {
    [super loadView];
}

- (void)viewDidUnload {
    [refreshView removeFromSuperview];
    [refreshView release];
    refreshView = nil;
    
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [refreshView refreshLastUpdatedDate];
    [tableView addSubview:refreshView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    // Don't show the loading indicator until it has loaded at all.
    if ([[(HNEntry *) source entries] count] > 0) {
        return 2;
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [[(HNEntry *) source entries] count];
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        HNEntry *entry = [[(HNEntry *) source entries] objectAtIndex:[indexPath row]];
        return [SubmissionTableCell heightForEntry:entry withWidth:[[self view] bounds].size.width];
    } else {
        return 64.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        SubmissionTableCell *cell = (SubmissionTableCell *) [tableView dequeueReusableCellWithIdentifier:@"submission"];
        if (cell == nil) cell = [[[SubmissionTableCell alloc] initWithReuseIdentifier:@"submission"] autorelease];
    
        HNEntry *entry = [[(HNEntry *) source entries] objectAtIndex:[indexPath row]];
        [cell setSubmission:entry];
        return cell;
    } else {
        LoadingTableCell *cell = (LoadingTableCell *) [tableView dequeueReusableCellWithIdentifier:@"loading"];
        if (cell == nil) cell = [[[LoadingTableCell alloc] initWithReuseIdentifier:@"loading"] autorelease];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        HNEntry *entry = [[(HNEntry *) source entries] objectAtIndex:[indexPath row]];
    
        CommentListController *controller = [[CommentListController alloc] initWithSource:entry];
        [controller setTitle:@"Submission"];
        [[self navigationController] pushViewController:[controller autorelease] animated:YES];
    }
}

- (void)finishedLoading {
    [super finishedLoading];
    
    if (refreshView == nil) {
        refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableView.bounds.size.height, [self view].frame.size.width, tableView.bounds.size.height)];
        [refreshView setDelegate:self];
    }
    
    [tableView addSubview:refreshView];
    [refreshView setFrame:CGRectMake(0.0f, 0.0f - tableView.bounds.size.height, [self view].frame.size.width, tableView.bounds.size.height)];
    
	[refreshView egoRefreshScrollViewDataSourceDidFinishedLoading:tableView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
	[refreshView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[refreshView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[source beginReloading];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
	return [source isLoading];
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
     // XXX: what should really go here?
	return [NSDate date];
}

AUTOROTATION_FOR_PAD_ONLY

@end
