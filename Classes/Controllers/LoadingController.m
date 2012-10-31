//
//  LoadingController.m
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "LoadingController.h"

#import "HNKit.h"

#import "SharingController.h"

#import "LoadingIndicatorView.h"
#import "ProgressHUD.h"

#import "UIActionSheet+Context.h"
#import "UINavigationItem+MultipleItems.h"

@implementation LoadingController
@synthesize source;

#pragma mark - Source Management

- (void)setSource:(HNObject *)source_ {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHNObjectStartedLoadingNotification object:source];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHNObjectFinishedLoadingNotification object:source];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHNObjectFailedLoadingNotification object:source];
    
    [source autorelease];
    source = [source_ retain];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sourceStartedLoading) name:kHNObjectStartedLoadingNotification object:source];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sourceFinishedLoading) name:kHNObjectFinishedLoadingNotification object:source];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sourceFailedLoading) name:kHNObjectFailedLoadingNotification object:source];

    if ([source isLoading]) {
        // Fake a loading started event if it's already loading (show spinners).
        [self sourceStartedLoading];
    } else if ([source isLoaded]) {
        // Fake a finished loading event even if it's loaded (to show content).
        [self finishedLoading];
    } else {
        // Start loading if we're not either loading or loaded already.
        [source beginLoading];
    }
}

- (NSString *)sourceTitle {
    return nil;
}

- (id)initWithSource:(HNObject *)source_ {
    if ((self = [super init])) {
        [self setSource:source_];
        
        statusViews = [[NSMutableSet alloc] init];
    }
    
    return self;
}

#pragma mark - Lifecycle

- (void)loadView {
    [super loadView];
    
    indicator = [[LoadingIndicatorView alloc] initWithFrame:CGRectZero];
    [indicator setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    retryButton = [[PlacardButton alloc] initWithFrame:CGRectZero];
    [retryButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [retryButton setTitle:@"Retry Loading" forState:UIControlStateNormal];
    [retryButton addTarget:self action:@selector(retryPressed) forControlEvents:UIControlEventTouchUpInside];
    
    actionItem = [[BarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionTapped)];
    
    statusView = [[UIView alloc] initWithFrame:[self.view bounds]];
    [statusView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [statusView setBackgroundColor:[UIColor whiteColor]];
    [statusView setHidden:YES];
    [[self view] addSubview:statusView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [[self navigationItem] addLeftBarButtonItem:actionItem atPosition:UINavigationItemPositionRight];
    } else {
        [[self navigationItem] addRightBarButtonItem:actionItem atPosition:UINavigationItemPositionLeft];
    }
    
    [self updateStatusDisplay];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    for (UIView *view in statusViews) {
        [self removeStatusView:statusView];
    }
    
    [[self navigationItem] removeBarButtonItem:actionItem];
    
    [indicator release];
    indicator = nil;
    [actionItem release];
    actionItem = nil;
    [retryButton release];
    retryButton = nil;
    [statusView release];
    statusView = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    if ([source isLoading]) [source cancelLoading];
    
    [indicator release];
    [source release];
    [actionItem release];
    [retryButton release];
    [statusView release];
    [statusViews release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([source isLoaded]) {
        // Fake a finished loading event even if it's loaded (to show content).
        [self finishedLoading];
    } else if ([source isLoading]) {
        // We're currently loading, so update the status display (below).
    } else {
        // Start loading if we're not either loading or loaded already.
        [source beginLoading];
    }
    
    [self updateStatusDisplay];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - Status Views

- (void)removeStatusView:(UIView *)view {
    if (view == nil) return;
    
    [statusViews removeObject:view];
    [view removeFromSuperview];
    
    if ([statusViews count] == 0) {
        [statusView setHidden:YES];
    }
}

- (void)addStatusView:(UIView *)view {
    if (view == nil) return;
    
    [view setFrame:[statusView bounds]];
    
    [statusViews addObject:view];
    [statusView addSubview:view];
    
    if ([statusViews count] != 0) {
        [statusView setHidden:NO];
    }
}

- (void)updateStatusDisplay {
    [self removeStatusView:retryButton];
    [self removeStatusView:indicator];
    
    if ([source isLoaded]) {
        // we're fine, don't show anything
    } else if ([source isLoading]) {
        [self addStatusView:indicator];
    } else {
        [self addStatusView:retryButton];
        
        CGRect buttonFrame;
        buttonFrame.size.width = 180.0f;
        buttonFrame.size.height = 40.0f;
        buttonFrame.origin.x = floorf(([statusView bounds].size.width / 2) - (buttonFrame.size.width / 2));
        buttonFrame.origin.y = floorf(([statusView bounds].size.height / 2) - (buttonFrame.size.height / 2));
        [retryButton setFrame:buttonFrame];
    }
}

#pragma mark - Loading

- (void)objectChangedLoadingState:(HNObject *)object {
}

- (void)sourceStartedLoading {
    [self updateStatusDisplay];
}

- (void)sourceFailedLoading {
    // If the source has already loaded before, we have *some* data to show,
    // so just show that and show a dialog to let the user know it failed.
    if ([source isLoaded]) {
        ProgressHUD *hud = [[ProgressHUD alloc] init];
        [hud setText:@"Error Loading"];
        [hud setState:kProgressHUDStateError];
        [hud showInWindow:[self.view window]];
        [hud dismissAfterDelay:0.8f animated:YES];
        [hud release];
    }
    
    [self updateStatusDisplay];
}

- (void)sourceFinishedLoading {
    [self finishedLoading];
    
    [self updateStatusDisplay];
}

- (void)finishedLoading {
    // Overridden in subclasses.
}

#pragma mark - Actions

- (void)retryPressed {
    [source beginLoading];
}

- (void)actionTapped {
    SharingController *sharingController = [[SharingController alloc] initWithURL:[source URL] title:[self sourceTitle] fromController:self];
    [sharingController showFromBarButtonItem:actionItem];
    [sharingController release];
}

AUTOROTATION_FOR_PAD_ONLY

@end
