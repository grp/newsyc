//
//  EntryListController.m
//  newsyc
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"

#import "EntryListController.h"
#import "LoadingIndicatorView.h"
#import "PullToRefreshView.h"

#import "CommentTableCell.h"
#import "SubmissionTableCell.h"

#import "CommentListController.h"

@implementation EntryListController

- (void)dealloc {
    [pullToRefreshView release];
    [tableView release];
    [emptyLabel release];
    [entries release];
    
    [super dealloc];
}

- (void)loadView {
    [super loadView];
    
    tableView = [[UITableView alloc] initWithFrame:[[self view] bounds] style:UITableViewStylePlain];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setTableFooterView:statusView];
    [[self view] addSubview:tableView];
    
    emptyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [emptyLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [emptyLabel setBackgroundColor:[UIColor whiteColor]];
    [emptyLabel setTextColor:[UIColor grayColor]];
    [emptyLabel setText:@"No items."];
    [emptyLabel setTextAlignment:UITextAlignmentCenter];
    
    pullToRefreshView = [[PullToRefreshView alloc] initWithScrollView:tableView];
    [tableView addSubview:pullToRefreshView];
    [pullToRefreshView setDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [emptyLabel release];
    emptyLabel = nil;
    [pullToRefreshView release];
    pullToRefreshView = nil;
    [tableView release];
    tableView = nil;
    
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

- (void)sourceStartedLoading {
    [super sourceStartedLoading];
    
    [pullToRefreshView setState:PullToRefreshViewStateLoading];
}

- (void)sourceFinishedLoading {
    [super sourceFinishedLoading];
    
    [pullToRefreshView finishedLoading];
}

- (void)sourceFailedLoading {
    [super sourceFailedLoading];
    
    [pullToRefreshView finishedLoading];
}

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    [source beginLoading];
}

- (CGFloat)statusOffsetHeight {
    return 0.0f;
}

- (void)addStatusView:(UIView *)view resize:(BOOL)resize {
    CGRect frame = CGRectZero;
    frame.size.width = [tableView bounds].size.width;
    CGFloat height = [tableView bounds].size.height - [self statusOffsetHeight];
    frame.size.height = height >= 50.0f ? height : 50.0f;
    if (resize) [view setFrame:frame];
    [statusView setFrame:frame];
    
    [view setBackgroundColor:[UIColor clearColor]];
    
    [statusView addSubview:view];
    [tableView setTableFooterView:statusView];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // XXX: this is a hack :(
    if (statusView == indicator) {
        [tableView setContentOffset:CGPointZero];
        [tableView setScrollEnabled:NO];
    }
}

- (void)removeStatusView:(UIView *)view {
    [super removeStatusView:view];
    
    // XXX: this is a hack :(
    if ([[statusView subviews] count] == 0) {
        [tableView setTableFooterView:nil];
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    }
    
    // XXX: this is a hack :(
    if (statusView == indicator) {
        [tableView setScrollEnabled:YES];
    }
}

- (void)loadEntries {
    [entries release];
    entries = [[(HNEntry *) source entries] copy];
}

- (void)finishedLoading {
    [self loadEntries];
        
    [tableView reloadData];

    if ([tableView numberOfSections] == 0 || [tableView numberOfRowsInSection:0] == 0) {
        [self addStatusView:emptyLabel];
    } else {
        [self removeStatusView:emptyLabel];
    }
}

- (HNEntry *)entryAtIndexPath:(NSIndexPath *)indexPath {
    return [entries objectAtIndex:[indexPath row]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return [source isLoaded] ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [entries count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HNEntry *entry = [self entryAtIndexPath:indexPath];
    if ([entry isSubmission]) return [SubmissionTableCell heightForEntry:entry withWidth:[[self view] bounds].size.width];
    else return [CommentTableCell heightForEntry:entry withWidth:[[self view] bounds].size.width];
}

- (void)configureCell:(UITableViewCell *)cell forEntry:(HNEntry *)entry {
    if ([entry isSubmission]) {
        SubmissionTableCell *cell_ = (SubmissionTableCell *) cell;
        [cell_ setSubmission:entry];
    } else if ([entry isComment]) {
        CommentTableCell *cell_ = (CommentTableCell *) cell;
        [cell_ setComment:entry];
    }
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HNEntry *entry = [self entryAtIndexPath:indexPath];
    
    if ([entry isSubmission]) {
        SubmissionTableCell *cell = (SubmissionTableCell *) [tableView dequeueReusableCellWithIdentifier:@"submission"];
        if (cell == nil) cell = [[[SubmissionTableCell alloc] initWithReuseIdentifier:@"submission"] autorelease];
        
        [self configureCell:cell forEntry:entry];
        
        return cell;
    } else if ([entry isComment]) {
        CommentTableCell *cell = (CommentTableCell *) [tableView dequeueReusableCellWithIdentifier:@"comment"];
        if (cell == nil) cell = [[[CommentTableCell alloc] initWithReuseIdentifier:@"comment"] autorelease];

        [self configureCell:cell forEntry:entry];
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HNEntry *entry = [self entryAtIndexPath:indexPath];
    
    CommentListController *controller = [[CommentListController alloc] initWithSource:entry];
    if ([entry isSubmission]) [controller setTitle:@"Submission"];
    if ([entry isComment]) [controller setTitle:@"Replies"];
    [[self navigationController] pushViewController:[controller autorelease] animated:YES];
}

- (void)tableView:(UITableView *)table willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == [tableView numberOfSections] - 1 
        && [indexPath row] == [tableView numberOfRowsInSection:[tableView numberOfSections] - 1]) {
        // XXX: load more items? (if possible for this entry type?)
        // [source beginLoadingWithTarget:self action:@selector(sourceDidFinishLoading:)];
    }
}

AUTOROTATION_FOR_PAD_ONLY

@end
