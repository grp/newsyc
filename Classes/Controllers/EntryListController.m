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
    [moreButton release];

    [super dealloc];
}

- (void)loadView {
    [super loadView];
    
    tableView = [[UITableView alloc] initWithFrame:[[self view] bounds] style:UITableViewStylePlain];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [[self view] addSubview:tableView];
    
    emptyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [emptyLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [emptyLabel setTextColor:[UIColor grayColor]];
    [emptyLabel setBackgroundColor:[UIColor clearColor]];
    [emptyLabel setText:@"No Items"];
    [emptyLabel setTextAlignment:UITextAlignmentCenter];
    
    pullToRefreshView = [[PullToRefreshView alloc] initWithScrollView:tableView];
    [tableView addSubview:pullToRefreshView];
    [pullToRefreshView setDelegate:self];
    
    [[self view] bringSubviewToFront:statusView];
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
    [moreButton release];
    moreButton = nil;
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

- (void)sourceStartedLoading {
    [super sourceStartedLoading];
    
    [pullToRefreshView setState:PullToRefreshViewStateLoading];
}

- (void)sourceFinishedLoading {
    [super sourceFinishedLoading];
    
    [pullToRefreshView finishedLoading];
    [moreButton stopLoading];
    
    if ([source isKindOfClass:[HNEntryList class]]) {
        if ([(HNEntryList *) source moreToken] != nil) {
            moreButton = [[LoadMoreButton alloc] initWithFrame:CGRectMake(0, 0, [[self view] bounds].size.width, 64.0f)];
            [moreButton addTarget:self action:@selector(loadMorePressed) forControlEvents:UIControlEventTouchUpInside];
            [tableView setTableFooterView:moreButton];
        } else {
            [tableView setTableFooterView:nil];
            [moreButton release];
            moreButton = nil;
        }
    }
}

- (void)sourceFailedLoading {
    [super sourceFailedLoading];
    
    [pullToRefreshView finishedLoading];
    [moreButton stopLoading];
}

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    [source beginLoading];
}

- (void)loadEntries {
    [entries release];
    entries = [[(HNEntry *) source entries] copy];
}

- (void)showEmptyLabel {
    [self addStatusView:emptyLabel];
    [emptyLabel setFrame:[statusView bounds]];
}

- (void)removeEmptyLabel {
    [self removeStatusView:emptyLabel];
}

- (void)finishedLoading {
    [self loadEntries];
    
    [tableView reloadData];

    if ([tableView numberOfSections] == 0 || [tableView numberOfRowsInSection:0] == 0) {
        [self showEmptyLabel];
    } else {
        [self removeEmptyLabel];
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
    else return [CommentTableCell heightForEntry:entry withWidth:[[self view] bounds].size.width showReplies:YES];
}

- (void)configureCell:(UITableViewCell *)cell forEntry:(HNEntry *)entry {
    if ([entry isSubmission]) {
        SubmissionTableCell *cell_ = (SubmissionTableCell *) cell;
        [cell_ setSubmission:entry];
    } else if ([entry isComment]) {
        CommentTableCell *cell_ = (CommentTableCell *) cell;
        [cell_ setIndentationLevel:0];
        [cell_ setShowReplies:YES];
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
    [[self navigationController] pushViewController:[controller autorelease] animated:YES];
}

- (void)loadMorePressed {
    if ([source isLoaded] && ![(HNEntryList *) source isLoadingMore]) {
        [(HNEntryList *) source beginLoadingMore];
        [moreButton startLoading];
    }
}

AUTOROTATION_FOR_PAD_ONLY

@end
