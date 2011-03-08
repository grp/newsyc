//
//  EntryListController.m
//  Orangey
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNKit.h"

#import "EntryListController.h"

@implementation EntryListController

- (void)dealloc {
    [tableView release];
    
    [super dealloc];
}

- (void)loadView {
    [super loadView];
    
    tableView = [[UITableView alloc] initWithFrame:[[self view] bounds] style:UITableViewStylePlain];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [[self view] addSubview:tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [tableView release];
    tableView = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

- (void)addLabelWithTitle:(NSString *)title {
    CGRect frame = CGRectZero;
    frame.size.width = [tableView bounds].size.width;
    frame.size.height = [tableView bounds].size.height - [[tableView tableHeaderView] bounds].size.height;
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    [label setText:title];
    [label setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor grayColor]];
    [label setTextAlignment:UITextAlignmentCenter];
    [tableView setTableFooterView:[label autorelease]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)finishedLoading {
    [tableView reloadData];
    
    if (![source loaded]) {
        [self addLabelWithTitle:@"Error loading."];
    } else if ([tableView numberOfSections] == 0 || [tableView numberOfRowsInSection:0] == 0) {
        [self addLabelWithTitle:@"No items."];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)tableView:(UITableView *)table willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == [tableView numberOfSections] - 1 
        && [indexPath row] == [tableView numberOfRowsInSection:[tableView numberOfSections] - 1]
        && [source isKindOfClass:[HNEntryList class]]) {
        // XXX: load more items?
        // [source beginLoadingWithTarget:self action:@selector(sourceDidFinishLoading:)];
    }
}

@end
