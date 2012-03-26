//
//  EmptyController.m
//  newsyc
//
//  Created by Grant Paul on 3/22/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "EmptyController.h"

@implementation EmptyController

- (void)dealloc {
    [tableView release];
    [emptyLabel release];
    
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [tableView release];
    tableView = nil;
    [emptyLabel release];
    emptyLabel = nil;
}

- (void)loadView {
    [super loadView];
        
    tableView = [[OrangeTableView alloc] initWithFrame:[[self view] bounds]];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [[self view] addSubview:tableView];
    
    emptyLabel = [[UILabel alloc] initWithFrame:[[self view] bounds]];
    [emptyLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [emptyLabel setText:@"No Submission Selected"];
    [emptyLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [emptyLabel setTextAlignment:UITextAlignmentCenter];
    [emptyLabel setShadowColor:[UIColor whiteColor]];
    [emptyLabel setShadowOffset:CGSizeMake(0, 1)];
    [emptyLabel setBackgroundColor:[UIColor clearColor]];
    [[self view] addSubview:emptyLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [tableView setOrange:![[NSUserDefaults standardUserDefaults] boolForKey:@"disable-orange"]];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disable-orange"]) {
        [emptyLabel setTextColor:[UIColor grayColor]];
    } else {
        [emptyLabel setTextColor:[UIColor grayColor]];
    }
}

AUTOROTATION_FOR_PAD_ONLY

@end
