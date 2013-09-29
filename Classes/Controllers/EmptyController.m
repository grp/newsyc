//
//  EmptyController.m
//  newsyc
//
//  Created by Grant Paul on 3/22/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "EmptyController.h"
#import "EmptyView.h"
#import "OrangeTableView.h"

@implementation EmptyController

- (void)dealloc {
    [tableView release];
    [emptyView release];
    
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [tableView release];
    tableView = nil;
    [emptyView release];
    emptyView = nil;
}

- (void)loadView {
    [super loadView];
        
    tableView = [[OrangeTableView alloc] initWithFrame:[[self view] bounds]];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [[self view] addSubview:tableView];
    
    emptyView = [[EmptyView alloc] initWithFrame:[[self view] bounds]];
    [emptyView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [emptyView setText:@"No Submission Selected"];
    [emptyView setBackgroundColor:[UIColor clearColor]];
    [[self view] addSubview:emptyView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [tableView setOrange:![[NSUserDefaults standardUserDefaults] boolForKey:@"disable-orange"]];
}

AUTOROTATION_FOR_PAD_ONLY

@end
