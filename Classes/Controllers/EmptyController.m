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
    [tableBackgroundView release];
    [emptyLabel release];
    
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [tableView release];
    tableView = nil;
    [tableBackgroundView release];
    tableBackgroundView = nil;
    [emptyLabel release];
    emptyLabel = nil;
}

- (void)loadView {
    [super loadView];
        
    tableView = [[UITableView alloc] initWithFrame:[[self view] bounds] style:UITableViewStyleGrouped];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [[self view] addSubview:tableView];
    
    tableBackgroundView = [[tableView backgroundView] retain];
    
    emptyLabel = [[UILabel alloc] initWithFrame:[[self view] bounds]];
    [emptyLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [emptyLabel setText:@"Welcome to news:yc!"];
    [emptyLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [emptyLabel setTextAlignment:UITextAlignmentCenter];
    [emptyLabel setTextColor:[UIColor darkGrayColor]];
    [emptyLabel setShadowColor:[UIColor whiteColor]];
    [emptyLabel setShadowOffset:CGSizeMake(0, 1)];
    [[self view] addSubview:emptyLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disable-orange"]) {
        UIView *backgroundView = [[[UIView alloc] initWithFrame:[tableView bounds]] autorelease];
        [backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [tableView setBackgroundColor:[UIColor clearColor]];
        [backgroundView setBackgroundColor:[UIColor colorWithRed:(242.0f / 255.0f) green:(205.0f / 255.0f) blue:(175.0f / 255.0f) alpha:1.0f]];
        [tableView setBackgroundView:backgroundView];
    } else {
        [tableView setBackgroundView:tableBackgroundView];
    }
}

AUTOROTATION_FOR_PAD_ONLY

@end
