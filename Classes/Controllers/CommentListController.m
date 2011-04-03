//
//  CommentListController.m
//  newsyc
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HNKit.h"

#import "UIActionSheet+Context.h"

#import "CommentListController.h"
#import "CommentTableCell.h"
#import "HeaderContainerView.h"
#import "DetailsHeaderView.h"
#import "SubmissionDetailsHeaderView.h"
#import "CommentDetailsHeaderView.h"
#import "EntryActionsView.h"
#import "ProfileController.h"
#import "NavigationController.h"
#import "EntryReplyComposeController.h"
#import "BrowserController.h"

@implementation CommentListController

- (void)detailsHeaderView:(DetailsHeaderView *)header selectedURL:(NSURL *)url {
    BrowserController *controller = [[BrowserController alloc] initWithURL:url];
    [[self navigationController] pushViewController:[controller autorelease] animated:YES];
}

- (void)submission:(id)submission didSubmitVote:(NSNumber *)submitted error:(NSError *)error {
    if (![submitted boolValue]) {
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setTitle:@"Error Voting"];
        [alert setMessage:@"Unable to submit your vote. Make sure you can perform this vote and haven't already."];
        [alert addButtonWithTitle:@"Continue"];
        [alert show];
        [alert release];
    }
    
    [tableView reloadData];
    [headerContainerView setNeedsDisplay];
}

- (void)submission:(id)submission didSubmitFlag:(NSNumber *)submitted error:(NSError *)error {
    if (![submitted boolValue]) {
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setTitle:@"Error Flagging"];
        [alert setMessage:@"Unable to submit your vote. Make sure you can flag items and haven't already."];
        [alert addButtonWithTitle:@"Continue"];
        [alert show];
        [alert release];
    }
    
    [tableView reloadData];
    [headerContainerView setNeedsDisplay];
}

- (void)actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(NSInteger)index {
    if ([[sheet sheetContext] isEqual:@"flag"]) {
        if (index == [sheet destructiveButtonIndex]) {
            [[HNSession currentSession] flagEntry:(HNEntry *) source target:self action:@selector(submission:didSubmitFlag:error:)];
        }
    } else {
        if ([[[self class] superclass] instancesRespondToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
            [super actionSheet:sheet clickedButtonAtIndex:index];
        }
    }
}

- (void)completeAction {
    EntryActionsViewItem item = savedItem;
    
    if (item == kEntryActionsViewItemSubmitter) {
        ProfileController *controller = [[ProfileController alloc] initWithSource:[(HNEntry *) source submitter]];
        [controller setTitle:@"Profile"];
        [[self navigationController] pushViewController:[controller autorelease] animated:YES];
    } else if (item == kEntryActionsViewItemUpvote) {
        [[HNSession currentSession] voteEntry:(HNEntry *) source inDirection:kHNVoteDirectionUp target:self action:@selector(submission:didSubmitVote:error:)];
    } else if (item == kEntryActionsViewItemDownvote) {
        [[HNSession currentSession] voteEntry:(HNEntry *) source inDirection:kHNVoteDirectionDown target:self action:@selector(submission:didSubmitVote:error:)];
    } else if (item == kEntryActionsViewItemFlag) {
        UIActionSheet *sheet = [[UIActionSheet alloc] init];
        [sheet addButtonWithTitle:@"Flag"];
        [sheet addButtonWithTitle:@"Cancel"];
        [sheet setDestructiveButtonIndex:0];
        [sheet setCancelButtonIndex:1];
        [sheet setDelegate:self];
        [sheet setSheetContext:@"flag"];
        [sheet showInView:[[self view] window]];
        [sheet release];
    } else if (item == kEntryActionsViewItemReply) {
        NavigationController *navigation = [[NavigationController alloc] init];
        EntryReplyComposeController *compose = [[EntryReplyComposeController alloc] initWithEntry:(HNEntry *) source];
        [navigation setViewControllers:[NSArray arrayWithObject:[compose autorelease]]];
        [[self navigationController] presentModalViewController:[navigation autorelease] animated:YES];
    }
}

- (void)loginControllerDidLogin:(LoginController *)controller {
    [self dismissModalViewControllerAnimated:YES];
    
    // When a modal view controller is dismissed, you can't present another one
    // until you get the -viewDidAppear: message called. Because this might cause
    // a modal view to be presented, we need to use this ivar to have it delayed 
    // until when -viewDidAppear: is called.
    shouldCompleteOnAppear = YES;
}

- (void)loginControllerDidCancel:(LoginController *)controller {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)entryActionsView:(EntryActionsView *)eav didSelectItem:(EntryActionsViewItem)item {
    savedItem = item;
    
    if (item == kEntryActionsViewItemSubmitter || [HNSession currentSession] != nil) {
        [self completeAction];
    } else {
        LoginController *login = [[LoginController alloc] init];
        [login setDelegate:self];
        NavigationController *navigation = [[NavigationController alloc] initWithRootViewController:[login autorelease]];
        [[self navigationController] presentModalViewController:[navigation autorelease] animated:YES];
    }
}

- (void)dealloc {
    [containerContainer release];
    [headerContainerView release];
    [entryActionsView release];
    
    [super dealloc];
}

- (BOOL)hasHeaderAndFooter {
    return [source type] == kHNPageTypeItemComments; 
}

- (void)finishedLoading {
    [super finishedLoading];
}

- (void)updateHeaderPositioning {
    CGFloat offset = [tableView contentOffset].y;
    if (suggestedHeaderHeight < maximumHeaderHeight || (offset > suggestedHeaderHeight - maximumHeaderHeight || offset <= 0)) {
        CGRect frame = [headerContainerView frame];
        if (suggestedHeaderHeight - maximumHeaderHeight > 0 && offset > 0) offset -= suggestedHeaderHeight - maximumHeaderHeight;
        frame.origin.y = offset;
        frame.size.height = suggestedHeaderHeight - offset;
        [headerContainerView setFrame:frame];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateHeaderPositioning];
}

- (void)loadView {
    [super loadView];
    
    if ([self hasHeaderAndFooter]) {
        entryActionsView = [[EntryActionsView alloc] initWithFrame:CGRectZero];
        [entryActionsView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        [entryActionsView sizeToFit];
        CGRect actionsFrame = [entryActionsView frame];
        actionsFrame.origin.y = [[self view] frame].size.height - actionsFrame.size.height;
        actionsFrame.size.width = [[self view] frame].size.width;
        [entryActionsView setFrame:actionsFrame];
        [entryActionsView setDelegate:self];
        [entryActionsView setEntry:(HNEntry *) source];
        [[self view] addSubview:entryActionsView];
        
        CGRect tableFrame = [tableView frame];
        tableFrame.size.height = [[self view] bounds].size.height - actionsFrame.size.height;
        [tableView setFrame:tableFrame];
        
        headerContainerView = [[HeaderContainerView alloc] initWithEntry:(HNEntry *) source widthWidth:[[self view] bounds].size.width];
        [headerContainerView setClipsToBounds:YES];
        [headerContainerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
        [[headerContainerView detailsHeaderView] setDelegate:self];
        
        UIView *shadow = [[UIView alloc] initWithFrame:CGRectMake(-50.0f, [headerContainerView bounds].size.height, [[self view] bounds].size.width + 100.0f, 1.0f)];
        CALayer *layer = [shadow layer];
        [layer setShadowOffset:CGSizeMake(0, -2.0f)];
        [layer setShadowRadius:5.0f];
        [layer setShadowColor:[[UIColor blackColor] CGColor]];
        [layer setShadowOpacity:1.0f];
        [shadow setBackgroundColor:[UIColor grayColor]];
        [shadow setClipsToBounds:NO];
        
        containerContainer = [[UIView alloc] initWithFrame:[headerContainerView bounds]];
        [containerContainer setBackgroundColor:[UIColor clearColor]];
        [containerContainer addSubview:headerContainerView];
        [containerContainer addSubview:[shadow autorelease]];
        [containerContainer setClipsToBounds:NO];
        [tableView setTableHeaderView:containerContainer];
        
        suggestedHeaderHeight = [headerContainerView bounds].size.height;
        maximumHeaderHeight = [tableView bounds].size.height - 44.0f;
        [self updateHeaderPositioning];
    }
}

- (CGFloat)statusOffsetHeight {
    return suggestedHeaderHeight;
}

- (void)viewDidUnload {
    [containerContainer release];
    containerContainer = nil;
    [entryActionsView release];
    entryActionsView = nil;
    [headerContainerView release];
    headerContainerView = nil;
    
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (shouldCompleteOnAppear) {
        shouldCompleteOnAppear = NO;
        [self completeAction];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return [source isLoaded] ? 1 : 0;
}

- (HNEntry *)entryAtIndexPath:(NSIndexPath *)indexPath {
    return [[(HNEntry *) source entries] objectAtIndex:[indexPath row]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[(HNEntry *) source entries] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HNEntry *entry = [self entryAtIndexPath:indexPath];
    return [CommentTableCell heightForEntry:entry withWidth:[[self view] bounds].size.width];
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentTableCell *cell = (CommentTableCell *) [tableView dequeueReusableCellWithIdentifier:@"comment"];
    if (cell == nil) cell = [[[CommentTableCell alloc] initWithReuseIdentifier:@"comment"] autorelease];
    
    HNEntry *entry = [self entryAtIndexPath:indexPath];
    [cell setComment:entry];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HNEntry *entry = [self entryAtIndexPath:indexPath];
    
    CommentListController *controller = [[CommentListController alloc] initWithSource:(HNObject *) entry];
    [controller setTitle:@"Replies"];
    [[self navigationController] pushViewController:[controller autorelease] animated:YES];
}

@end
