//
//  LoadingController.m
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"

#import "UIActionSheet+Context.h"
#import "ProgressHUD.h"

#import "LoadingController.h"
#import "LoadingIndicatorView.h"

@implementation LoadingController
@synthesize source;

- (void)setSource:(HNObject *)source_ {
    [source autorelease];
    source = [source_ retain];
    [source setDelegate:self];
}

- (id)initWithSource:(HNObject *)source_ {
    if ((self = [super init])) {
        [self setSource:source_];
    }
    
    return self;
}

- (void)dealloc {
    [indicator release];
    if ([source isLoading]) [source cancelLoading];
    if ([source delegate] == self) [source setDelegate:nil];
    [source release];
    [actionItem release];
    [retryButton release];
    [loadingItem release];
    [statusView release];

    [super dealloc];
}

- (void)finishedLoading {
    // Overridden in subclasses.
}

- (void)removeStatusView:(UIView *)view {
    [view removeFromSuperview];
}

- (void)addStatusView:(UIView *)view resize:(BOOL)resize {
    if (resize) {
        [statusView setFrame:[[self view] bounds]];
        [view setFrame:[[self view] bounds]];
    }
    
    [[self view] addSubview:view];
}

- (void)addStatusView:(UIView *)view {
    [self addStatusView:view resize:YES];
}

- (void)removeError {
    [self removeStatusView:retryButton];
}

- (void)showError {
    [self addStatusView:retryButton resize:NO];
    
    CGRect buttonFrame = [retryButton frame];
    buttonFrame.size.width = 180.0f;
    buttonFrame.size.height = 40.0f;
    buttonFrame.origin.x = floorf(([[retryButton superview] bounds].size.width / 2) - (buttonFrame.size.width / 2));
    buttonFrame.origin.y = floorf(([[retryButton superview] bounds].size.height / 2) - (buttonFrame.size.height / 2));
    [retryButton setFrame:buttonFrame];
}

- (void)objectChangedLoadingState:(HNObject *)object {
    
}

- (void)objectStartedLoading:(id)object {
    [[self navigationItem] setRightBarButtonItem:loadingItem];
    
    if (![source isLoaded]) {
        [self removeError];
        [self addStatusView:indicator];
    }
}

- (void)object:(HNObject *)source_ failedToLoadWithError:(NSError *)error {
    [self removeStatusView:indicator];
    
    // If the source has already loaded before, we have *some* data to show, so
    // just show that. Otherwise, show a dialog to let the user know it failed.
    if (![source isLoaded]) {
        [self showError];
    } else {
        ProgressHUD *hud = [[ProgressHUD alloc] init];
        [hud setText:@"Error Loading"];
        [hud setState:kProgressHUDStateError];
        [hud showInWindow:[self.view window]];
        [hud dismissAfterDelay:0.8f animated:YES];
        [hud release];
    }
    
    [[self navigationItem] setRightBarButtonItem:actionItem animated:YES];
}

- (void)objectFinishedLoading:(HNObject *)object; {
    [self removeStatusView:indicator];
    
    [[self navigationItem] setRightBarButtonItem:actionItem animated:YES];
    [self finishedLoading];
}

- (void)actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(NSInteger)index {
    if ([[sheet sheetContext] isEqual:@"link"]) {
        if (index == [sheet cancelButtonIndex]) return;
    
        NSInteger first = [sheet firstOtherButtonIndex];
        if (index == first) {
            [[UIApplication sharedApplication] openURL:[source URL]];
        } else if (index == first + 1) {
            // XXX: find the best way to copy a URL to the clipboard
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setURL:[source URL]];
            [pasteboard setString:[[source URL] absoluteString]];
            
            ProgressHUD *hud = [[ProgressHUD alloc] init];
            [hud setText:@"Copied!"];
            [hud setState:kProgressHUDStateCompleted];
            [hud showInWindow:[self.view window]];
            [hud dismissAfterDelay:0.8f animated:YES];
            [hud release];
        }
    }
}

- (void)actionTapped {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Safari", @"Copy Link", nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [sheet showFromBarButtonItem:actionItem animated:YES];
    else [sheet showInView:[[self view] window]];
    
    [sheet setSheetContext:@"link"];
    [sheet release];
}

- (void)retryPressed {
    [self removeError];
    
    [source beginLoading];
}

- (void)loadView {
    [super loadView];
    
    indicator = [[LoadingIndicatorView alloc] initWithFrame:CGRectZero];
    [indicator setBackgroundColor:[UIColor whiteColor]];
    [indicator setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    retryButton = [[PlacardButton alloc] initWithFrame:CGRectZero];
    [retryButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [retryButton setTitle:@"Retry Loading" forState:UIControlStateNormal];
    [retryButton addTarget:self action:@selector(retryPressed) forControlEvents:UIControlEventTouchUpInside];
    
    actionItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionTapped)];
    loadingItem = [[ActivityIndicatorItem alloc] initWithSize:CGSizeMake(27.0f, kActivityIndicatorItemStandardSize.height)];
    
    statusView = [[UIView alloc] initWithFrame:CGRectZero];
    [statusView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:statusView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationItem] setRightBarButtonItem:actionItem];
}

- (void)viewDidUnload {
    [indicator release];
    indicator = nil;
    [actionItem release];
    actionItem = nil;
    [loadingItem release];
    loadingItem = nil;
    [retryButton release];
    retryButton = nil;
    [statusView release];
    statusView = nil;
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![source isLoaded]) {
        [source beginLoading];
    } else {
        // Fake a finished loading event if it's already
        // loaded, since we want to show some content.
        [self finishedLoading];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

AUTOROTATION_FOR_PAD_ONLY

@end
