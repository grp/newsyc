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

- (id)initWithSource:(HNObject *)source_ {
    if ((self = [super init])) {
        [self setSource:source_];
    }
    
    return self;
}

- (void)dealloc {
    [indicator release];
    if ([source isLoading]) [source cancelLoading];
    [source release];
    [actionItem release];
    [retryButton release];
    [statusView release];
    [statusViews release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];

    [super dealloc];
}

- (void)finishedLoading {
    // Overridden in subclasses.
}

- (void)removeStatusView:(UIView *)view {
    [statusViews removeObject:view];
    [view removeFromSuperview];
    
    if ([statusViews count] == 0) {
        [statusView setHidden:YES];
    }
}

- (void)addStatusView:(UIView *)view {
    [statusViews addObject:view];
    [statusView addSubview:view];
    
    if ([statusViews count] != 0) {
        [statusView setHidden:NO];
    }
}

- (void)showIndicator {
    [self addStatusView:indicator];
    
    [indicator setFrame:[statusView bounds]];
}

- (void)removeIndicator {
    [self removeStatusView:indicator];
}

- (void)removeError {
    [self removeStatusView:retryButton];
}

- (void)showError {
    [self addStatusView:retryButton];
    
    CGRect buttonFrame = [retryButton frame];
    buttonFrame.size.width = 180.0f;
    buttonFrame.size.height = 40.0f;
    buttonFrame.origin.x = floorf(([statusView bounds].size.width / 2) - (buttonFrame.size.width / 2));
    buttonFrame.origin.y = floorf(([statusView bounds].size.height / 2) - (buttonFrame.size.height / 2));
    [retryButton setFrame:buttonFrame];
}

- (void)objectChangedLoadingState:(HNObject *)object {
    
}

- (void)sourceStartedLoading {
    if (![source isLoaded]) {
        [self removeError];
        [self showIndicator];
    }
}

- (void)sourceFailedLoading {
    [self removeIndicator];
    
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
}

- (void)appRelaunched:(NSNotification *)notification {
    // fake a finished loading here to reload to account for changed preferences
    // (this is only set up when we finish loading, so assume we are loaded)
    [self finishedLoading];
}

- (void)sourceFinishedLoading {
    [self removeIndicator];
    
    [self finishedLoading];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appRelaunched:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)addActions:(UIActionSheet *)sheet {
    openInSafariIndex = [sheet addButtonWithTitle:@"Open in Safari"];
    mailLinkIndex = [MFMailComposeViewController canSendMail] ? [sheet addButtonWithTitle:@"Mail Link"] : -1;
    copyLinkIndex = [sheet addButtonWithTitle:@"Copy Link"];
}

- (void)actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(NSInteger)index {
    if ([[sheet sheetContext] isEqual:@"link"]) {
        if (index == [sheet cancelButtonIndex]) return;

        if (index == openInSafariIndex) {
            [[UIApplication sharedApplication] openURL:[source URL]];
        } else if (index == mailLinkIndex) {
            MFMailComposeViewController *composeController = [[MFMailComposeViewController alloc] init];
            [composeController setMailComposeDelegate:self];

            NSString *urlString = [[source URL] absoluteString];
            NSString *body = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", urlString, urlString];
            [composeController setMessageBody:body isHTML:YES];

            [self presentModalViewController:[composeController autorelease] animated:YES];
        } else if (index == copyLinkIndex) {
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

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)actionTapped {
    UIActionSheet *sheet = [[UIActionSheet alloc]
        initWithTitle:nil
        delegate:self
        cancelButtonTitle:nil
        destructiveButtonTitle:nil
        otherButtonTitles:nil
    ];

    [self addActions:sheet];
    [sheet addButtonWithTitle:@"Cancel"];
    [sheet setCancelButtonIndex:([sheet numberOfButtons] - 1)];
    
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
    [indicator setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    retryButton = [[PlacardButton alloc] initWithFrame:CGRectZero];
    [retryButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [retryButton setTitle:@"Retry Loading" forState:UIControlStateNormal];
    [retryButton addTarget:self action:@selector(retryPressed) forControlEvents:UIControlEventTouchUpInside];
    
    actionItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionTapped)];
    
    statusView = [[UIView alloc] initWithFrame:[self.view bounds]];
    [statusView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [statusView setBackgroundColor:[UIColor whiteColor]];
    [statusView setHidden:YES];
    [[self view] addSubview:statusView];
    
    statusViews = [[NSMutableSet alloc] init];
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
    [retryButton release];
    retryButton = nil;
    [statusView release];
    statusView = nil;
    [statusViews release];
    statusViews = nil;

    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

AUTOROTATION_FOR_PAD_ONLY

@end
