//
//  CommentListController.m
//  newsyc
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HNKit.h"

#import "UIActionSheet+Context.h"

#import "CommentListController.h"
#import "CommentTableCell.h"
#import "DetailsHeaderView.h"
#import "EntryActionsView.h"
#import "ProfileController.h"
#import "NavigationController.h"
#import "EntryReplyComposeController.h"
#import "BrowserController.h"
#import "HackerNewsLoginController.h"

@implementation CommentListController

- (void)detailsHeaderView:(DetailsHeaderView *)header selectedURL:(NSURL *)url {
    BrowserController *controller = [[BrowserController alloc] initWithURL:url];
    [[self navigationController] pushViewController:[controller autorelease] animated:YES];
}

- (void)flagFinished {
    [entryActionsView stopLoadingItem:kEntryActionsViewItemFlag];
    [source beginReloading];
}

- (void)submissionFlagDidSucceedWithNotification:(NSNotification *)notification {
    [self flagFinished];
}

- (void)submissionFlagDidFailWithNotification:(NSNotification *)notification {
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Error Flagging"];
    [alert setMessage:@"Unable to submit your vote. Make sure you can flag items and haven't already."];
    [alert addButtonWithTitle:@"Continue"];
    [alert show];
    [alert release];
    
    [self flagFinished];
}

- (void)voteFailed {
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Error Voting"];
    [alert setMessage:@"Unable to submit your vote. Make sure you can vote and haven't already."];
    [alert addButtonWithTitle:@"Continue"];
    [alert show];
    [alert release];
}

- (void)upvoteFinished {
    [source beginReloading];
    [entryActionsView stopLoadingItem:kEntryActionsViewItemUpvote];
}

- (void)submissionUpvoteDidSucceedWithNotification:(NSNotification *)notification {
    [self upvoteFinished];
}

- (void)submissionUpvoteDidFailWithNotification:(NSNotification *)notification {
    [self voteFailed];
    [self upvoteFinished];
}

- (void)downvoteFinished {
    [entryActionsView stopLoadingItem:kEntryActionsViewItemDownvote];
}

- (void)submissionDownvoteDidSucceedWithNotification:(NSNotification *)notification {
    [source beginReloading];
    [self downvoteFinished];
}

- (void)submissionDownvoteDidFailWithNotification:(NSNotification *)notification {
    [self voteFailed];
    [self downvoteFinished];
}

- (void)composeControllerDidCancel:(ComposeController *)controller {
    // ignore
}

- (void)composeControllerDidSubmit:(ComposeController *)controller {
    [source beginReloading];
}

- (void)actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(NSInteger)index {
    if ([[sheet sheetContext] isEqual:@"flag"]) {
        if (index == [sheet destructiveButtonIndex]) {
            HNSubmission *submission = [[HNSubmission alloc] initWithSubmissionType:kHNSubmissionTypeFlag];
            [submission setTarget:(HNEntry *) source];
            [[HNSession currentSession] performSubmission:submission];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submissionFlagDidSucceedWithNotification:) name:kHNSubmissionSuccessNotification object:submission];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submissionFlagDidFailWithNotification:) name:kHNSubmissionFailureNotification object:submission];
            [submission release];
            
            [entryActionsView beginLoadingItem:kEntryActionsViewItemFlag];
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
        HNSubmission *submission = [[HNSubmission alloc] initWithSubmissionType:kHNSubmissionTypeVote];
        [submission setDirection:kHNVoteDirectionUp];
        [submission setTarget:(HNEntry *) source];
        [[HNSession currentSession] performSubmission:submission];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submissionUpvoteDidSucceedWithNotification:) name:kHNSubmissionSuccessNotification object:submission];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submissionUpvoteDidFailWithNotification:) name:kHNSubmissionFailureNotification object:submission];
        [submission release];
        
        [entryActionsView beginLoadingItem:kEntryActionsViewItemUpvote];
    } else if (item == kEntryActionsViewItemDownvote) {
        HNSubmission *submission = [[HNSubmission alloc] initWithSubmissionType:kHNSubmissionTypeVote];
        [submission setDirection:kHNVoteDirectionDown];
        [submission setTarget:(HNEntry *) source];
        [[HNSession currentSession] performSubmission:submission];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submissionDownvoteDidSucceedWithNotification:) name:kHNSubmissionSuccessNotification object:submission];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submissionDownvoteDidFailWithNotification:) name:kHNSubmissionFailureNotification object:submission];
        [submission release];
        
        [entryActionsView beginLoadingItem:kEntryActionsViewItemDownvote];
    } else if (item == kEntryActionsViewItemFlag) {
        UIActionSheet *sheet = [[UIActionSheet alloc] init];
        [sheet addButtonWithTitle:@"Flag"];
        [sheet addButtonWithTitle:@"Cancel"];
        [sheet setDestructiveButtonIndex:0];
        [sheet setCancelButtonIndex:1];
        [sheet setDelegate:self];
        [sheet setSheetContext:@"flag"];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [sheet showFromBarButtonItem:[entryActionsView barButtonItemForItem:kEntryActionsViewItemFlag] animated:YES];
        else [sheet showInView:[[self view] window]];
        [sheet release];
    } else if (item == kEntryActionsViewItemReply) {
        NavigationController *navigation = [[NavigationController alloc] init];
        EntryReplyComposeController *compose = [[EntryReplyComposeController alloc] initWithEntry:(HNEntry *) source];
        [compose setDelegate:self];
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
    
    if (item == kEntryActionsViewItemSubmitter || ![[HNSession currentSession] isAnonymous]) {
        [self completeAction];
    } else {
        LoginController *login = [[HackerNewsLoginController alloc] init];
        [login setDelegate:self];
        NavigationController *navigation = [[NavigationController alloc] initWithRootViewController:[login autorelease]];
        [[self navigationController] presentModalViewController:[navigation autorelease] animated:YES];
    }
}

- (void)dealloc {
    [containerContainer release];
    [detailsHeaderView release];
    [entryActionsView release];
    [detailsHeaderContainer release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (void)updateHeaderPositioning {
    // Disable the slide-over style headers if they are too tall. Just scroll normally in that case.
    if (suggestedHeaderHeight > maximumHeaderHeight) return;
    
    CGFloat offset = [tableView contentOffset].y;
    if (suggestedHeaderHeight < maximumHeaderHeight || (offset > suggestedHeaderHeight - maximumHeaderHeight || offset <= 0)) {
        CGRect frame = [detailsHeaderContainer frame];
        if (suggestedHeaderHeight - maximumHeaderHeight > 0 && offset > 0) offset -= suggestedHeaderHeight - maximumHeaderHeight;
        frame.origin.y = offset;
        frame.size.height = suggestedHeaderHeight - offset;
        [detailsHeaderContainer setFrame:frame];
    }
}

- (BOOL)hasHeaderAndFooter {
    return [[source type] isEqual:kHNPageTypeItemComments]; 
}

- (void)setupHeader {
    // Don't show the header if it doesn't make sense, and only show it if the source is at least partially loaded.
    if (![self hasHeaderAndFooter] || [(HNEntry *) source submitter] == nil) return;
    
    [detailsHeaderContainer release];
    detailsHeaderContainer = nil;
    [containerContainer release];
    containerContainer = nil;
    [entryActionsView release];
    entryActionsView = nil;
    [detailsHeaderView release];
    detailsHeaderView = nil;
    
    entryActionsView = [[EntryActionsView alloc] initWithFrame:CGRectZero];
    [entryActionsView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [entryActionsView sizeToFit];
    CGRect actionsFrame = [entryActionsView frame];
    actionsFrame.origin.y = [[self view] frame].size.height - actionsFrame.size.height;
    actionsFrame.size.width = [[self view] frame].size.width;
    [entryActionsView setFrame:actionsFrame];
    [entryActionsView setDelegate:self];
    [entryActionsView setEntry:(HNEntry *) source];
    [entryActionsView setEnabled:([(HNEntry *) source destination] == nil) forItem:kEntryActionsViewItemDownvote];
    [[self view] addSubview:entryActionsView];
    
    CGRect tableFrame = [tableView frame];
    tableFrame.size.height = [[self view] bounds].size.height - actionsFrame.size.height;
    [tableView setFrame:tableFrame];
    
    detailsHeaderView = [[DetailsHeaderView alloc] initWithEntry:(HNEntry *) source widthWidth:[[self view] bounds].size.width];
    [detailsHeaderView setClipsToBounds:YES];
    [detailsHeaderView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
    [detailsHeaderView setDelegate:self];
    
    detailsHeaderContainer = [[UIView alloc] initWithFrame:[detailsHeaderView bounds]];
    [detailsHeaderContainer addSubview:detailsHeaderView];
    [detailsHeaderContainer setClipsToBounds:YES];
    [detailsHeaderContainer setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
    [[detailsHeaderContainer layer] setContentsGravity:kCAGravityTopLeft];
    
    UIView *shadow = [[UIView alloc] initWithFrame:CGRectMake(-50.0f, [detailsHeaderView bounds].size.height, [[self view] bounds].size.width + 100.0f, 1.0f)];
    CALayer *layer = [shadow layer];
    [layer setShadowOffset:CGSizeMake(0, -2.0f)];
    [layer setShadowRadius:5.0f];
    [layer setShadowColor:[[UIColor blackColor] CGColor]];
    [layer setShadowOpacity:1.0f];
    [shadow setBackgroundColor:[UIColor grayColor]];
    [shadow setClipsToBounds:NO];
    [shadow setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    containerContainer = [[UIView alloc] initWithFrame:[detailsHeaderView bounds]];
    [containerContainer setBackgroundColor:[UIColor clearColor]];
    [containerContainer addSubview:detailsHeaderContainer];
    [containerContainer addSubview:[shadow autorelease]];
    [containerContainer setClipsToBounds:NO];
    [tableView setTableHeaderView:containerContainer];
    
    suggestedHeaderHeight = [detailsHeaderView bounds].size.height;
    maximumHeaderHeight = [tableView bounds].size.height - 64.0f;
    [self updateHeaderPositioning];
    [tableView setScrollsToTop:YES];
}

- (void)finishedLoading {
    [self setupHeader];
    
    [super finishedLoading];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateHeaderPositioning];
}

- (void)loadView {
    [super loadView];
    
    [self setupHeader];
}

- (CGFloat)statusOffsetHeight {
    return suggestedHeaderHeight;
}

- (void)viewDidUnload {
    [containerContainer release];
    containerContainer = nil;
    [entryActionsView release];
    entryActionsView = nil;
    [detailsHeaderView release];
    detailsHeaderView = nil;
    [detailsHeaderContainer release];
    detailsHeaderContainer = nil;
    
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

AUTOROTATION_FOR_PAD_ONLY

@end
