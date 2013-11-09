//
//  EntryListController.m
//  newsyc
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import <HNKit/HNKit.h>

#import "EntryListController.h"
#import "LoadingIndicatorView.h"
#import "PullToRefreshView.h"
#import "SubmissionTableCell.h"
#import "UIColor+Orange.h"
#import "EmptyView.h"
#import "CommentListController.h"

@implementation EntryListController

#pragma mark - Lifecycle

- (void)loadView {
    [super loadView];

    tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    [tableViewController setClearsSelectionOnViewWillAppear:NO];
    [self addChildViewController:tableViewController];

    tableView = [[tableViewController tableView] retain];
    [tableView setFrame:[[self view] bounds]];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setClipsToBounds:NO];
    [[self view] addSubview:tableView];
    
    emptyView = [[EmptyView alloc] initWithFrame:CGRectZero];
    [emptyView setText:@"No Items"];

    moreCell = [[LoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [[moreCell button] addTarget:self action:@selector(loadMorePressed) forControlEvents:UIControlEventTouchUpInside];

    if ([UIRefreshControl class] != nil) {
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(refreshFromRefreshControl:) forControlEvents:UIControlEventValueChanged];
        [tableViewController setRefreshControl:refreshControl];
    } else {
        pullToRefreshView = [[PullToRefreshView alloc] initWithScrollView:tableView];
        [tableView addSubview:pullToRefreshView];
        [pullToRefreshView setDelegate:self];
    }
    
    [[self view] bringSubviewToFront:statusView];
}

- (void)viewDidUnload {
    [super viewDidUnload];

    [emptyView release];
    emptyView = nil;
    [pullToRefreshView release];
    pullToRefreshView = nil;
    [refreshControl release];
    refreshControl = nil;
    [moreCell release];
    moreCell = nil;
    [tableView release];
    tableView = nil;
    [tableViewController removeFromParentViewController];
    [tableViewController release];
    tableViewController = nil;
}

- (void)dealloc {
    [pullToRefreshView release];
    [refreshControl endRefreshing];
    [refreshControl release];
    [emptyView release];
    [moreCell release];
    [tableView release];
    [tableViewController removeFromParentViewController];
    [tableViewController release];
    [entries release];

    [super dealloc];
}

- (void)deselectWithAnimation:(BOOL)animated {
    NSIndexPath *indexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:indexPath animated:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disable-orange"]) {
        [refreshControl setTintColor:[UIColor lightOrangeColor]];
    } else {
        [refreshControl setTintColor:nil];
    }

    [self deselectWithAnimation:YES];
}

#pragma mark - Loading

- (void)sourceStartedLoading {
    [super sourceStartedLoading];

    [refreshControl beginRefreshing];
    [pullToRefreshView setState:PullToRefreshViewStateLoading];
}

- (void)sourceFinishedLoading {
    [refreshControl endRefreshing];
    [pullToRefreshView finishedLoading];
    [[moreCell button] stopLoading];
    
    [super sourceFinishedLoading];
}

- (void)sourceFailedLoading {
    [super sourceFailedLoading];

    [refreshControl endRefreshing];
    [pullToRefreshView finishedLoading];
    [[moreCell button] stopLoading];
}

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    [source beginLoading];
}

- (void)refreshFromRefreshControl:(UIRefreshControl *)control {
    [source beginLoading];
}

- (void)loadEntries {
    [entries release];
    entries = [[(HNEntry *) source entries] copy];
}

- (void)updateStatusDisplay {
    [self removeStatusView:emptyView];
    
    [super updateStatusDisplay];
    
    if ([source isLoaded] && [entries count] == 0) {
        [self addStatusView:emptyView];
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

        Class cellClass = [[self class] cellClass];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(cellClass)];
        if (cell == nil) cell = [[[cellClass alloc] initWithReuseIdentifier:NSStringFromClass(cellClass)] autorelease];

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
