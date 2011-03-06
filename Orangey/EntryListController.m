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

- (void)finishedLoading {
    [tableView reloadData];
    if ([tableView numberOfSections] == 0 || [tableView numberOfRowsInSection:0] == 0) {
        CGRect frame = [tableView bounds];
        frame.origin.y += [[tableView tableHeaderView] bounds].size.height;
        frame.size.height -= [[tableView tableHeaderView] bounds].size.height;
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        [label setText:@"No items."];
        [label setFont:[UIFont boldSystemFontOfSize:17.0f]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor grayColor]];
        [label setTextAlignment:UITextAlignmentCenter];
        [tableView addSubview:label];
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
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
