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
    [pullToRefreshView release];
    
    [super dealloc];
}

- (void)loadView {
    [super loadView];
    
    pullToRefreshView = [[PullToRefreshView alloc] initWithScrollView:tableView];
    [tableView addSubview:pullToRefreshView];
    [pullToRefreshView setDelegate:self];
}

- (void)viewDidUnload {
    [pullToRefreshView release];
    pullToRefreshView = nil;
    
    [super viewDidUnload];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[(HNEntry *) source entries] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HNEntry *entry = [[(HNEntry *) source entries] objectAtIndex:[indexPath row]];
    return [SubmissionTableCell heightForEntry:entry withWidth:[[self view] bounds].size.width];
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SubmissionTableCell *cell = (SubmissionTableCell *) [tableView dequeueReusableCellWithIdentifier:@"submission"];
    if (cell == nil) cell = [[[SubmissionTableCell alloc] initWithReuseIdentifier:@"submission"] autorelease];
    
    HNEntry *entry = [[(HNEntry *) source entries] objectAtIndex:[indexPath row]];
    [cell setSubmission:entry];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HNEntry *entry = [[(HNEntry *) source entries] objectAtIndex:[indexPath row]];
    
    CommentListController *controller = [[CommentListController alloc] initWithSource:entry];
    [controller setTitle:@"Submission"];
    [[self navigationController] pushViewController:[controller autorelease] animated:YES];
}

- (void)objectStartedLoading:(HNObject *)object {
    [super objectStartedLoading:object];
    
    [pullToRefreshView setState:PullToRefreshViewStateLoading];
}

- (void)objectFinishedLoading:(HNObject *)object {
    [super objectFinishedLoading:object];
    
    [pullToRefreshView finishedLoading];
}

- (void)object:(HNObject *)object failedToLoadWithError:(NSError *)error {
    [super object:object failedToLoadWithError:error];
    
    [pullToRefreshView finishedLoading];
}

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    [source beginLoading];
}

- (void)addStatusView:(UIView *)view resize:(BOOL)resize {
    [super addStatusView:view resize:resize];
    
    [tableView setScrollEnabled:NO];
}

- (void)removeStatusView:(UIView *)view {
    [super removeStatusView:view];
    
    [tableView setScrollEnabled:YES];
}

AUTOROTATION_FOR_PAD_ONLY

@end
