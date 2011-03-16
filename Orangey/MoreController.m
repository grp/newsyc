//
//  MoreController.m
//  Orangey
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNKit.h"

#import "MoreController.h"
#import "ProfileController.h"
#import "ProfileHeaderView.h"
#import "SubmissionListController.h"
#import "CommentListController.h"

@implementation MoreController

- (void)dealloc {
    [tableView release];
    
    [super dealloc];
}

- (void)loadView {
    [super loadView];
    
    tableView = [[UITableView alloc] initWithFrame:[[self view] bounds] style:UITableViewStyleGrouped];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [[self view] addSubview:tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"More"];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return 2;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 3;
        case 1: return 2;
        default: return 0;
    }
}

- (CGFloat)tableView:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    cell = cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    if ([indexPath section] == 0) {
        if ([indexPath row] == 0) {
            [[cell textLabel] setText:@"Best Submissions"];
        } else if ([indexPath row] == 1) {
            [[cell textLabel] setText:@"Active Discussions"];
        } else if ([indexPath row] == 2) {
            [[cell textLabel] setText:@"Classic View"];
        }
    } else if ([indexPath section] == 1) {
        if ([indexPath row] == 0) {
            [[cell textLabel] setText:@"Best Comments"];
        } else if ([indexPath row] == 1) {
            [[cell textLabel] setText:@"New Comments"];
        }
    }
    return [cell autorelease];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Submissions";
    } else if (section == 1) {
        return @"Comments";
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HNPageType type = nil;
    Class class = nil;
    NSString *title = nil;
    
    if ([indexPath section] == 0) {
        class = [SubmissionListController class];
        
        if ([indexPath row] == 0) {
            type = kHNPageTypeBestSubmissions;
            title = @"Best Submissions";
        } else if ([indexPath row] == 1) {
            type = kHNPageTypeActiveSubmissions;
            title = @"Active";
        } else if ([indexPath row] == 2) {
            type = kHNPageTypeClassicSubmissions;
            title = @"Classic";
        }
    } else if ([indexPath section] == 1) {
        class = [CommentListController class];
        
        if ([indexPath row] == 0) {
            type = kHNPageTypeBestComments;
            title = @"Best Comments";
        } else if ([indexPath row] == 1) {
            type = kHNPageTypeNewComments;
            title = @"New Comments";
        }
    }
    
    HNEntry *entry = [[HNEntry alloc] initWithType:type];
    UIViewController *controller = [[class alloc] initWithSource:[entry autorelease]];
    [controller setTitle:title];
    [[self navigationController] pushViewController:[controller autorelease] animated:YES];
}

@end
