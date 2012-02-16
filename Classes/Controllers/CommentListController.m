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
    [source beginLoading];
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
    [source beginLoading];
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
    [source beginLoading];
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
    [source beginLoading];
}

- (void)performUpvote {
    HNSubmission *submission = [[HNSubmission alloc] initWithSubmissionType:kHNSubmissionTypeVote];
    [submission setDirection:kHNVoteDirectionUp];
    [submission setTarget:(HNEntry *) source];
    [[HNSession currentSession] performSubmission:submission];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submissionUpvoteDidSucceedWithNotification:) name:kHNSubmissionSuccessNotification object:submission];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submissionUpvoteDidFailWithNotification:) name:kHNSubmissionFailureNotification object:submission];
    [submission release];
    
    [entryActionsView beginLoadingItem:kEntryActionsViewItemUpvote];
}

- (void)performDownvote {
    HNSubmission *submission = [[HNSubmission alloc] initWithSubmissionType:kHNSubmissionTypeVote];
    [submission setDirection:kHNVoteDirectionDown];
    [submission setTarget:(HNEntry *) source];
    [[HNSession currentSession] performSubmission:submission];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submissionDownvoteDidSucceedWithNotification:) name:kHNSubmissionSuccessNotification object:submission];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submissionDownvoteDidFailWithNotification:) name:kHNSubmissionFailureNotification object:submission];
    [submission release];
    
    [entryActionsView beginLoadingItem:kEntryActionsViewItemDownvote];
}

- (void)addActions:(UIActionSheet *)sheet {
    [super addActions:sheet];
    if ([(HNEntry *)source parent]) {
        goToParentIndex = [sheet addButtonWithTitle:@"Go to Parent"];
        goToSubmissionIndex = [sheet addButtonWithTitle:@"Go to Submission"];
    }
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
    } else if ([[sheet sheetContext] isEqual:@"upvote"]) {
        if (index != [sheet cancelButtonIndex]) {
            [self performUpvote];
        }
    } else if ([[sheet sheetContext] isEqual:@"downvote"]) {
        if (index != [sheet cancelButtonIndex]) {
            [self performDownvote];
        }
    } else if ([[sheet sheetContext] isEqual:@"link"]) {
        if (index == goToParentIndex || index == goToSubmissionIndex) {
            HNEntry *entry = (HNEntry *)source;
            entry = (index == goToSubmissionIndex) ? [entry submission] : [entry parent];

            CommentListController *controller = [[CommentListController alloc] initWithSource:entry];
            if ([entry isSubmission]) [controller setTitle:@"Submission"];
            if ([entry isComment]) [controller setTitle:@"Replies"];
            [[self navigationController] pushViewController:[controller autorelease] animated:YES];

        } else {
            [super actionSheet:sheet clickedButtonAtIndex:index];
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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *confirm = [defaults objectForKey:@"interface-confirm-votes"];
        if (confirm != nil && [confirm boolValue]) {
            UIActionSheet *sheet = [[UIActionSheet alloc] init];
            [sheet addButtonWithTitle:@"Vote"];
            [sheet addButtonWithTitle:@"Cancel"];
            [sheet setCancelButtonIndex:1];
            [sheet setDelegate:self];
            [sheet setSheetContext:@"upvote"];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [sheet showFromBarButtonItem:[entryActionsView barButtonItemForItem:kEntryActionsViewItemUpvote] animated:YES];
            else [sheet showInView:[[self view] window]];
            [sheet release];
        } else {
            [self performUpvote];
        }
    } else if (item == kEntryActionsViewItemDownvote) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *confirm = [defaults objectForKey:@"interface-confirm-votes"];
        if (confirm != nil && [confirm boolValue]) {
            UIActionSheet *sheet = [[UIActionSheet alloc] init];
            [sheet addButtonWithTitle:@"Vote"];
            [sheet addButtonWithTitle:@"Cancel"];
            [sheet setCancelButtonIndex:1];
            [sheet setDelegate:self];
            [sheet setSheetContext:@"downvote"];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [sheet showFromBarButtonItem:[entryActionsView barButtonItemForItem:kEntryActionsViewItemDownvote] animated:YES];
            else [sheet showInView:[[self view] window]];
            [sheet release];
        } else {
            [self performDownvote];
        }
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
    // until the -viewDidAppear: message is called. Because this might cause a
    // modal view to be presented, we need to use this ivar to have it delayed 
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

- (void)addStatusView:(UIView *)view {
    [super addStatusView:view];
    
    CGRect statusFrame = [statusView frame];
    statusFrame.size.height = [tableView bounds].size.height - suggestedHeaderHeight;
    if (statusFrame.size.height < 64.0f) statusFrame.size.height = 64.0f;    
    [statusView setFrame:statusFrame];
    
    if ([statusViews count] != 0) {
        [tableView setTableFooterView:statusView];
    }
}

- (void)removeStatusView:(UIView *)view {
    [super removeStatusView:view];
    
    if ([statusViews count] == 0) {
        [statusView setFrame:CGRectZero];
        [tableView setTableFooterView:statusView];
    }
}

- (void)setupHeader {
    // Only show it if the source is at least partially loaded.
    if ([(HNEntry *) source submitter] == nil) return;
    
    [detailsHeaderContainer release];
    detailsHeaderContainer = nil;
    [containerContainer release];
    containerContainer = nil;
    [detailsHeaderView release];
    detailsHeaderView = nil;
    
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
            
    // necessary since the core text view can steal this
    [tableView setScrollsToTop:YES];
}

- (void)addChildrenOfEntry:(HNEntry *)entry toEntryArray:(NSMutableArray *)array includeChildren:(BOOL)includeChildren {
    // only show children of comments that are fully loaded
    includeChildren = includeChildren && [entry isLoaded] && [entry isKindOfClass:[HNEntry class]];
    
    for (HNEntry *child in [entry entries]) {
        [array addObject:child];
        
        if (includeChildren) {
            [self addChildrenOfEntry:child toEntryArray:array includeChildren:includeChildren];
        }
    }
}

- (void)loadEntries {
    BOOL includeChildren = [[NSUserDefaults standardUserDefaults] boolForKey:@"show-nested-comments"];
    
    NSMutableArray *children = [NSMutableArray array];
    [self addChildrenOfEntry:(HNEntry *) source toEntryArray:children includeChildren:includeChildren]; 
    
    [entries release];
    entries = [children copy];
}

// XXX: this is really really slow :(
- (int)depthOfEntry:(HNEntry *)entry {
    int depth = 0;
    
    HNEntry *parent = [entry parent];
    
    // parent can be nil if we the parent is unknown. this is usually because it
    // is a child of an entry list, not of an entry itself, so we don't know.
    if (parent == nil) return 0;
    
    while (parent != source && parent != nil) {
        depth += 1;
        parent = [parent parent];
    }
    
    // don't show it at some crazy indentation level if this happens
    if (parent == nil) return 0;
    
    return depth;
}

- (CGFloat)tableView:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HNEntry *entry = [self entryAtIndexPath:indexPath];
    BOOL showReplies = ![[NSUserDefaults standardUserDefaults] boolForKey:@"show-nested-comments"];
    
    if ([entry isComment]) {
        return [CommentTableCell heightForEntry:entry withWidth:[[self view] bounds].size.width showReplies:showReplies indentationLevel:[self depthOfEntry:entry]];
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (void)configureCell:(CommentTableCell *)cell forEntry:(HNEntry *)entry {
    [super configureCell:cell forEntry:entry];
    
    if ([entry isComment]) {
        BOOL showReplies = ![[NSUserDefaults standardUserDefaults] boolForKey:@"show-nested-comments"];
        
        [cell setIndentationLevel:[self depthOfEntry:entry]];
        [cell setShowReplies:showReplies];
    }
}

- (void)finishedLoading {
    [self setupHeader];
    
    [super finishedLoading];
}

- (void)loadView {
    [super loadView];
    
    [emptyLabel setText:@"No Comments"];
    [statusView setBackgroundColor:[UIColor clearColor]];
    
    [self setupHeader];
        
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
    
    [pullToRefreshView setBackgroundColor:[UIColor whiteColor]];
    [pullToRefreshView setTextShadowColor:[UIColor whiteColor]];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disable-orange"]) {
        [entryActionsView setTintColor:[UIColor colorWithRed:1.0f green:0.4f blue:0.0f alpha:1.0f]];
    } else {
        [entryActionsView setTintColor:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (shouldCompleteOnAppear) {
        shouldCompleteOnAppear = NO;
        [self completeAction];
    }
}

AUTOROTATION_FOR_PAD_ONLY

@end
