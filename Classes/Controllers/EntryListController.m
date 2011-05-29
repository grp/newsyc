//
//  EntryListController.m
//  newsyc
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
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
    
    emptyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [emptyLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [emptyLabel setBackgroundColor:[UIColor whiteColor]];
    [emptyLabel setTextColor:[UIColor grayColor]];
    [emptyLabel setText:@"No items."];
    [emptyLabel setTextAlignment:UITextAlignmentCenter];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [tableView release];
    tableView = nil;
    
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

- (CGFloat)statusOffsetHeight {
    return 0.0f;
}

- (void)addStatusView:(UIView *)view resize:(BOOL)resize {
    if (resize) {
        CGRect frame;
        frame.origin.x = 0;
        frame.origin.y = [self statusOffsetHeight];
        frame.size.width = [tableView bounds].size.width;
        CGFloat height = [tableView bounds].size.height - [self statusOffsetHeight];
        frame.size.height = height >= 44.0f ? height : 44.0f;
        [view setFrame:frame];
    }
    
    [view setBackgroundColor:[UIColor clearColor]];
    
    [tableView addSubview:view];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)removeStatusView:(UIView *)view {
    [super removeStatusView:view];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
}

- (void)finishedLoading {
    [tableView reloadData];
    
    if ([tableView numberOfSections] == 0 || [tableView numberOfRowsInSection:0] == 0) {
        [self addStatusView:emptyLabel];
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

- (void)relayoutView {
    [tableView reloadData];
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
