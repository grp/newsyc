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

@interface CommentListController ()

- (void)setupHeader;

@end

@implementation CommentListController

#pragma mark - Lifecycle

- (void)finishedLoading {
    [self setupHeader];
    
    [super finishedLoading];
}

- (void)loadView {
    [super loadView];
    
    [emptyLabel setText:@"No Comments"];
    [statusView setBackgroundColor:[UIColor clearColor]];
    
    [self setupHeader];
    
    if ([source isKindOfClass:[HNEntry class]]) {
        entryActionsView = [[EntryActionsView alloc] initWithFrame:CGRectZero];
        [entryActionsView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        [entryActionsView sizeToFit];
        
        CGRect actionsFrame = [entryActionsView frame];
        actionsFrame.origin.y = [[self view] frame].size.height - actionsFrame.size.height;
        actionsFrame.size.width = [[self view] frame].size.width;
        [entryActionsView setFrame:actionsFrame];
        [entryActionsView setDelegate:self];
        [entryActionsView setEntry:(HNEntry *) source];
        [entryActionsView setEnabled:[(HNEntry *) source isComment] forItem:kEntryActionsViewItemDownvote];
        [[self view] addSubview:entryActionsView];
    
        CGRect tableFrame = [tableView frame];
        tableFrame.size.height = [[self view] bounds].size.height - actionsFrame.size.height;
        [tableView setFrame:tableFrame];
    }
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
    
    if ([source isKindOfClass:[HNEntry class]]) {
        if ([(HNEntry *) source isSubmission]) [self setTitle:@"Submission"];
        if ([(HNEntry *) source isComment]) [self setTitle:@"Replies"];
    } else {
        [self setTitle:@"Comments"];
    }
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
        
        savedAction();
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

#pragma mark - Table Cells

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
    NSMutableArray *children = [NSMutableArray array];
    [self addChildrenOfEntry:(HNEntry *) source toEntryArray:children includeChildren:YES]; 
    
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

- (CGFloat)cellHeightForEntry:(HNEntry *)entry {
    CGFloat height = [CommentTableCell heightForEntry:entry withWidth:[[self view] bounds].size.width expanded:(entry == expandedEntry) indentationLevel:[self depthOfEntry:entry]];

    return height;
}

+ (Class)cellClass {
    return [CommentTableCell class];
}

- (void)configureCell:(CommentTableCell *)cell forEntry:(HNEntry *)entry {
    [cell setDelegate:self];
    [cell setClipsToBounds:YES];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setIndentationLevel:[self depthOfEntry:entry]];
    [cell setComment:entry];
    [cell setExpanded:(entry == expandedEntry)];
}

- (void)setExpandedEntry:(HNEntry *)entry cell:(CommentTableCell *)cell {
    [tableView beginUpdates];
    [expandedCell setExpanded:NO];
    expandedEntry = entry;
    expandedCell = cell;
    [expandedCell setExpanded:YES];
    [tableView endUpdates];
}

#pragma mark - View Layout

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
    if (![source isKindOfClass:[HNEntry class]] || [(HNEntry *) source submitter] == nil) return;
    
    [pullToRefreshView setBackgroundColor:[UIColor whiteColor]];
    [pullToRefreshView setTextShadowColor:[UIColor whiteColor]];
    
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

#pragma mark - Delegates

- (void)detailsHeaderView:(DetailsHeaderView *)header selectedURL:(NSURL *)url {
    BrowserController *controller = [[BrowserController alloc] initWithURL:url];
    [[self navigationController] pushViewController:[controller autorelease] animated:YES];
}

- (void)commentTableCell:(CommentTableCell *)cell selectedURL:(NSURL *)url {
    BrowserController *controller = [[BrowserController alloc] initWithURL:url];
    [[self navigationController] pushViewController:[controller autorelease] animated:YES];
}

- (void)commentTableCellTapped:(CommentTableCell *)cell {
    if (expandedEntry != [cell comment]) {
        [self setExpandedEntry:[cell comment] cell:cell];
    } else {
        [self setExpandedEntry:nil cell:nil];
    }
}

- (void)commentTableCellDoubleTapped:(CommentTableCell *)cell {
    HNEntry *entry = [self entryAtIndexPath:[tableView indexPathForCell:cell]];
    CommentListController *controller = [[CommentListController alloc] initWithSource:entry];
    [[self navigationController] pushViewController:[controller autorelease] animated:YES];
}

#pragma mark - Actions

- (void)flagFailed {
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Error Flagging"];
    [alert setMessage:@"Unable to submit your vote. Make sure you can flag items and haven't already."];
    [alert addButtonWithTitle:@"Continue"];
    [alert show];
    [alert release];
}

- (void)voteFailed {
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Error Voting"];
    [alert setMessage:@"Unable to submit your vote. Make sure you can vote and haven't already."];
    [alert addButtonWithTitle:@"Continue"];
    [alert show];
    [alert release];
}

- (void)performUpvoteForEntry:(HNEntry *)entry fromEntryActionsView:(EntryActionsView *)eav {
    HNSubmission *submission = [[HNSubmission alloc] initWithSubmissionType:kHNSubmissionTypeVote];
    [submission setDirection:kHNVoteDirectionUp];
    [submission setTarget:entry];
    
    __block id successToken = nil;
    successToken = [[NSNotificationCenter defaultCenter] addObserverForName:kHNSubmissionSuccessNotification object:submission queue:nil usingBlock:^(NSNotification *block) {
        [entry beginLoading];
        [eav stopLoadingItem:kEntryActionsViewItemUpvote];
        
        [[NSNotificationCenter defaultCenter] removeObserver:successToken];        
    }];
    
    __block id failureToken = nil;
    failureToken = [[NSNotificationCenter defaultCenter] addObserverForName:kHNSubmissionFailureNotification object:submission queue:nil usingBlock:^(NSNotification *block) {
        [self voteFailed];
        [eav stopLoadingItem:kEntryActionsViewItemUpvote];
        
        [[NSNotificationCenter defaultCenter] removeObserver:failureToken];
    }];
    
    [[HNSession currentSession] performSubmission:submission];
    [submission release];
    
    [eav beginLoadingItem:kEntryActionsViewItemUpvote];
}

- (void)performDownvoteForEntry:(HNEntry *)entry fromEntryActionsView:(EntryActionsView *)eav {
    HNSubmission *submission = [[HNSubmission alloc] initWithSubmissionType:kHNSubmissionTypeVote];
    [submission setDirection:kHNVoteDirectionDown];
    [submission setTarget:entry];
    
    __block id successToken = nil;
    successToken = [[NSNotificationCenter defaultCenter] addObserverForName:kHNSubmissionSuccessNotification object:submission queue:nil usingBlock:^(NSNotification *block) {
        [entry beginLoading];
        [eav stopLoadingItem:kEntryActionsViewItemDownvote];
        
        [[NSNotificationCenter defaultCenter] removeObserver:successToken];        
    }];
                                             
    __block id failureToken = nil;
    failureToken = [[NSNotificationCenter defaultCenter] addObserverForName:kHNSubmissionFailureNotification object:submission queue:nil usingBlock:^(NSNotification *block) {
        [self voteFailed];
        [eav stopLoadingItem:kEntryActionsViewItemDownvote];
        
        [[NSNotificationCenter defaultCenter] removeObserver:failureToken];
    }];
    
    [[HNSession currentSession] performSubmission:submission];
    [submission release];
    
    [eav beginLoadingItem:kEntryActionsViewItemDownvote];
}

- (void)performFlagForEntry:(HNEntry *)entry fromEntryActionsView:(EntryActionsView *)eav {
    HNSubmission *submission = [[HNSubmission alloc] initWithSubmissionType:kHNSubmissionTypeFlag];
    [submission setTarget:entry];
    
    __block id successToken = nil;
    successToken = [[NSNotificationCenter defaultCenter] addObserverForName:kHNSubmissionSuccessNotification object:submission queue:nil usingBlock:^(NSNotification *block) {
        [entry beginLoading];
        [eav stopLoadingItem:kEntryActionsViewItemFlag];
        
        [[NSNotificationCenter defaultCenter] removeObserver:successToken];        
    }];
    
    __block id failureToken = nil;
    failureToken = [[NSNotificationCenter defaultCenter] addObserverForName:kHNSubmissionFailureNotification object:submission queue:nil usingBlock:^(NSNotification *block) {
        [self flagFailed];
        [eav stopLoadingItem:kEntryActionsViewItemFlag];
        
        [[NSNotificationCenter defaultCenter] removeObserver:failureToken];
    }];
    
    [[HNSession currentSession] performSubmission:submission];

    [submission release];
    
    [eav beginLoadingItem:kEntryActionsViewItemFlag];
}

- (void)composeControllerDidCancel:(EntryReplyComposeController *)controller {
    return;
}

- (void)composeControllerDidSubmit:(EntryReplyComposeController *)controller {
    [[controller entry] beginLoading];
}

- (void)clearSavedCompletion {
    [savedCompletion release];
    savedCompletion = nil;
}

- (void)clearSavedAction {
    [savedAction release];
    savedAction = nil;
}

- (void)actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(NSInteger)index {
    if ([[sheet sheetContext] isEqual:@"entry-action"]) {
        if (index != [sheet cancelButtonIndex]) {
            // The 2 is subtracted to cancel out the cancel button, and then
            // to account for the zero-indexed buttons, but the count from one.
            savedCompletion([sheet numberOfButtons] - 1 - index - 1);
        } else {
            [self clearSavedCompletion];
        }
    } else {
        if ([[[self class] superclass] instancesRespondToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
            [super actionSheet:sheet clickedButtonAtIndex:index];
        }
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
    
    [self clearSavedAction];
    [self clearSavedCompletion];
}

- (void)entryActionsView:(EntryActionsView *)eav didSelectItem:(EntryActionsViewItem)item {
    HNEntry *entry = [eav entry];
    
    __block __typeof__(self) this = self;
    
    savedCompletion = [^(int index) {
        if (item == kEntryActionsViewItemReply) {
            EntryReplyComposeController *compose = [[EntryReplyComposeController alloc] initWithEntry:entry];
            [compose setDelegate:this];
            
            NavigationController *navigation = [[NavigationController alloc] initWithRootViewController:compose];
            [[this navigationController] presentModalViewController:[navigation autorelease] animated:YES];
        } else if (item == kEntryActionsViewItemUpvote) {
            [this performUpvoteForEntry:entry fromEntryActionsView:eav];
        } else if (item == kEntryActionsViewItemFlag) {
            [this performFlagForEntry:entry fromEntryActionsView:eav];
        } else if (item == kEntryActionsViewItemDownvote) {
            [this performDownvoteForEntry:entry fromEntryActionsView:eav];            
        } else if (item == kEntryActionsViewItemActions) {
            if (index == 0) {
                ProfileController *controller = [[ProfileController alloc] initWithSource:[entry submitter]];
                [controller setTitle:@"Profile"];
                [[this navigationController] pushViewController:[controller autorelease] animated:YES];
            } else if (index == 1) {
                CommentListController *controller = [[CommentListController alloc] initWithSource:[entry parent]];
                [[this navigationController] pushViewController:[controller autorelease] animated:YES];
            } else if (index == 2) {
                CommentListController *controller = [[CommentListController alloc] initWithSource:[entry submission]];
                [[this navigationController] pushViewController:[controller autorelease] animated:YES];
            }
        }
        
        [this clearSavedCompletion];
    } copy];
    
    savedAction = [^{
        if (item == kEntryActionsViewItemUpvote || item == kEntryActionsViewItemDownvote) {
            NSNumber *confirm = [[NSUserDefaults standardUserDefaults] objectForKey:@"interface-confirm-votes"];
            
            if (confirm != nil && [confirm boolValue]) {
                UIActionSheet *sheet = [[UIActionSheet alloc] init];
                [sheet addButtonWithTitle:@"Vote"];
                [sheet addButtonWithTitle:@"Cancel"];
                [sheet setCancelButtonIndex:1];
                [sheet setDelegate:this];
                [sheet setSheetContext:@"entry-action"];
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [sheet showFromBarButtonItem:[entryActionsView barButtonItemForItem:item] animated:YES];
                else [sheet showInView:[[this view] window]];
                [sheet release];
            } else {
                savedCompletion(0);
            }
        } else if (item == kEntryActionsViewItemFlag) {
            UIActionSheet *sheet = [[UIActionSheet alloc] init];
            [sheet addButtonWithTitle:@"Flag"];
            [sheet addButtonWithTitle:@"Cancel"];
            [sheet setDestructiveButtonIndex:0];
            [sheet setCancelButtonIndex:1];
            [sheet setDelegate:this];
            [sheet setSheetContext:@"entry-action"];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [sheet showFromBarButtonItem:[entryActionsView barButtonItemForItem:item] animated:YES];
            else [sheet showInView:[[this view] window]];
            [sheet release];
        } else if (item == kEntryActionsViewItemActions) {
            UIActionSheet *sheet = [[UIActionSheet alloc] init];
            if ([entry submission]) [sheet addButtonWithTitle:@"Submission"];
            if ([entry parent]) [sheet addButtonWithTitle:@"Parent"];
            [sheet addButtonWithTitle:@"Submitter"];
            [sheet addButtonWithTitle:@"Cancel"];
            [sheet setCancelButtonIndex:([sheet numberOfButtons] - 1)];
            [sheet setDelegate:this];
            [sheet setSheetContext:@"entry-action"];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [sheet showFromBarButtonItem:[entryActionsView barButtonItemForItem:item] animated:YES];
            else [sheet showInView:[[this view] window]];
            [sheet release];
        } else if (item == kEntryActionsViewItemReply) {
            savedCompletion(0);
        }
        
        [this clearSavedAction];
    } copy];
    
    if (![[HNSession currentSession] isAnonymous] || item == kEntryActionsViewItemActions) {
        savedAction();
    } else {
        LoginController *login = [[HackerNewsLoginController alloc] init];
        [login setDelegate:this];
        NavigationController *navigation = [[NavigationController alloc] initWithRootViewController:[login autorelease]];
        [[this navigationController] presentModalViewController:[navigation autorelease] animated:YES];
    }
}


AUTOROTATION_FOR_PAD_ONLY

@end
