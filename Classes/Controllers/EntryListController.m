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

#import "SubmissionTableCell.h"

#import "CommentListController.h"

@implementation EntryListController

#pragma mark - Lifecycle

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
    
    moreCell = [[LoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [[moreCell button] addTarget:self action:@selector(loadMorePressed) forControlEvents:UIControlEventTouchUpInside];
    
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
    [moreCell release];
    moreCell = nil;
    
    [super viewDidUnload];
}

- (void)dealloc {
    [pullToRefreshView release];
    [tableView release];
    [emptyLabel release];
    [entries release];
    [moreCell release];
    
    [super dealloc];
}

- (void)deselectWithAnimation:(BOOL)animated {
    NSIndexPath *indexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:indexPath animated:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self deselectWithAnimation:YES];
}

#pragma mark - Loading

- (void)sourceStartedLoading {
    [super sourceStartedLoading];
    
    [pullToRefreshView setState:PullToRefreshViewStateLoading];
}

- (void)sourceFinishedLoading {
    [pullToRefreshView finishedLoading];
    [[moreCell button] stopLoading];
    
    [super sourceFinishedLoading];
}

- (void)sourceFailedLoading {
    [super sourceFailedLoading];
    
    [pullToRefreshView finishedLoading];
    [[moreCell button] stopLoading];
}

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    [source beginLoading];
}

- (void)loadEntries {
    [entries release];
    entries = [[(HNEntry *) source entries] copy];
}

- (void)updateStatusDisplay {
    [self removeStatusView:emptyLabel];
    
    [super updateStatusDisplay];
    
    if ([source isLoaded] && [entries count] == 0) {
        [self addStatusView:emptyLabel];
    }
}

- (void)finishedLoading {
    NSIndexPath *selectedIndexPath = [tableView indexPathForSelectedRow];
    HNEntry *selected = nil;
    if (selectedIndexPath != nil) selected = [self entryAtIndexPath:selectedIndexPath];
    
    [self loadEntries];
    [tableView reloadData];
    
    if (selectedIndexPath != nil) {
        NSIndexPath *indexPathOfSelected = [self indexPathOfEntry:selected];
        [tableView selectRowAtIndexPath:indexPathOfSelected animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

#pragma mark - Table View

- (NSIndexPath *)indexPathOfEntry:(HNEntry *)entry {
    return [NSIndexPath indexPathForRow:[entries indexOfObject:entry] inSection:0];
}

- (HNEntry *)entryAtIndexPath:(NSIndexPath *)indexPath {
    return [entries objectAtIndex:[indexPath row]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    if ([source isLoaded]) {
        if ([(HNContainer *) source moreToken] != nil) {
            // Show more token if available.
            return 2;
        } else {
            return 1;
        }
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [entries count];
    } else {
        return 1;
    }
}

- (CGFloat)cellHeightForEntry:(HNEntry *)entry {
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        HNEntry *entry = [self entryAtIndexPath:indexPath];
    
        return [self cellHeightForEntry:entry];
    } else {
        return 64.0f;
    }
}

+ (Class)cellClass {
    return nil;
}

- (void)configureCell:(UITableViewCell *)cell forEntry:(HNEntry *)entry {
    return;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        HNEntry *entry = [self entryAtIndexPath:indexPath];
    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"entry-cell"];
        if (cell == nil) cell = [[[[[self class] cellClass] alloc] initWithReuseIdentifier:@"entry-cell"] autorelease];

        [self configureCell:cell forEntry:entry];
    
        return cell;
    } else {
        return moreCell;
    }
}

- (void)cellSelected:(UITableViewCell *)cell forEntry:(HNEntry *)entry {
    return;
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HNEntry *entry = [self entryAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self cellSelected:cell forEntry:entry];
}

- (void)loadMorePressed {
    if ([source isLoaded] && ![(HNContainer *) source isLoadingMore]) {
        [(HNContainer *) source beginLoadingMore];
        [[moreCell button] startLoading];
    }
}

- (void)tableView:(UITableView *)tView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *lastCellIndexPath = [NSIndexPath indexPathForRow:([tView numberOfRowsInSection:0]-1) inSection:0];
    if (indexPath.row == lastCellIndexPath.row) {
        [self loadMorePressed];
        return;
    }
}

AUTOROTATION_FOR_PAD_ONLY

@end
