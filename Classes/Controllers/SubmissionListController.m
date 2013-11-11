//
//  SubmissionListController.m
//  newsyc
//
//  Created by Grant Paul on 2/24/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "SubmissionListController.h"

#import "SubmissionTableCell.h"
#import "CommentListController.h"
#import "BrowserController.h"

#import "AppDelegate.h"

@implementation SubmissionListController

+ (Class)cellClass {
    return [SubmissionTableCell class];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRecognized:)];
        swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.view addGestureRecognizer:swipeRecognizer];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];

    [swipeRecognizer release];
    swipeRecognizer = nil;
}

- (void)dealloc {
    [swipeRecognizer release];

    [super dealloc];
}

- (CGFloat)cellHeightForEntry:(HNEntry *)entry {
    return [SubmissionTableCell heightForEntry:entry withWidth:[[self view] bounds].size.width];
}

- (void)configureCell:(UITableViewCell *)cell forEntry:(HNEntry *)entry {
    SubmissionTableCell *cell_ = (SubmissionTableCell *) cell;
    [cell_ setSubmission:entry];
}

- (void)cellSelected:(UITableViewCell *)cell forEntry:(HNEntry *)entry {
    CommentListController *controller = [[CommentListController alloc] initWithSource:entry];
    [[self navigation] pushController:controller animated:YES];
    [controller release];
}

- (void)deselectWithAnimation:(BOOL)animated {
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
        [super deselectWithAnimation:animated];
    }
}

- (NSString *)sourceTitle {
    return [self title];
}

- (void)swipeRecognized:(UISwipeGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:location];

    HNEntry *entry = [self entryAtIndexPath:indexPath];

    NSArray *viewControllers = [[self navigation] controllers];

    CommentListController *commentController = [[CommentListController alloc] initWithSource:entry];
    viewControllers = [viewControllers arrayByAddingObject:commentController];
    [commentController release];

    BrowserController *browserController = [[BrowserController alloc] initWithURL:[entry destination]];
    viewControllers = [viewControllers arrayByAddingObject:browserController];
    [browserController release];

    // This bypasses the normal navigation flow, so only works for phone idioms.
    [[self navigation] setControllers:viewControllers animated:YES];
}

AUTOROTATION_FOR_PAD_ONLY

@end
