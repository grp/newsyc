//
//  LoadingController.m
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"

#import "UIActionSheet+Context.h"

#import "LoadingController.h"
#import "LoadingIndicatorView.h"

@implementation LoadingController
@synthesize source;

- (void)setSource:(HNObject *)source_ {
    [source autorelease];
    source = [source_ retain];
    [source setDelegate:self];

    loaded = NO;
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
    [loadingItem release];
    
    [super dealloc];
}

- (void)finishedLoading {
    // Overridden in subclasses.
}

- (void)removeStatusView:(UIView *)view {
    [view removeFromSuperview];
}

- (void)addStatusView:(UIView *)view resize:(BOOL)resize {
    if (resize) [view setFrame:[[self view] bounds]];
    [[self view] addSubview:view];
}

- (void)addStatusView:(UIView *)view {
    [self addStatusView:view resize:YES];
}

- (void)removeError {
    [self removeStatusView:errorLabel];
    [self removeStatusView:retryButton];
}

- (void)showErrorWithTitle:(NSString *)title {
    [errorLabel setText:title];
    [self addStatusView:errorLabel];
    [self addStatusView:retryButton resize:NO];
    
    CGRect buttonFrame = [retryButton frame];
    buttonFrame.size.width = 180.0f;
    buttonFrame.size.height = 44.0f;
    buttonFrame.origin.x = floorf(([[retryButton superview] bounds].size.width / 2) - (buttonFrame.size.width / 2));
    buttonFrame.origin.y = floorf(([[retryButton superview] bounds].size.height / 2) - (buttonFrame.size.height / 2)) + 60.0f;
    [retryButton setFrame:buttonFrame];
}

- (void)objectChangedLoadingState:(HNObject *)object {
    if ([object isLoading]) { 
        [[self navigationItem] setRightBarButtonItem:loadingItem];
    } else {
        [self removeStatusView:indicator];
    }
}

- (void)object:(HNObject *)source_ failedToLoadWithError:(NSError *)error {
    // If the source has already loaded before, we have *some* data to show,
    // so just show that. Otherwise, what really should happen is to:
    // XXX: show a non-modal loading error display if previously loaded
    if (![source isLoaded]) {
        [self showErrorWithTitle:@"Error loading."];
        loaded = NO;
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
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setURL:[source URL]];
            [pasteboard setString:[[source URL] absoluteString]];
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
    [self performInitialLoadIfPossible];
}

- (void)loadView {
    [super loadView];
    
    indicator = [[LoadingIndicatorView alloc] initWithFrame:CGRectZero];
    [indicator setBackgroundColor:[UIColor whiteColor]];
    [indicator setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    errorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [errorLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [errorLabel setBackgroundColor:[UIColor whiteColor]];
    [errorLabel setTextColor:[UIColor grayColor]];
    [errorLabel setTextAlignment:UITextAlignmentCenter];
    
    retryButton = [[PlacardButton alloc] initWithFrame:CGRectZero];
    [retryButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [retryButton setTitle:@"Retry Loading" forState:UIControlStateNormal];
    [retryButton addTarget:self action:@selector(retryPressed) forControlEvents:UIControlEventTouchUpInside];
    
    actionItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionTapped)];
    loadingItem = [[ActivityIndicatorItem alloc] initWithSize:CGSizeMake(27.0f, kActivityIndicatorItemStandardSize.height)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setRightBarButtonItem:actionItem];
}

- (void)viewDidUnload {
    [indicator release];
    indicator = nil;
    [errorLabel release];
    errorLabel = nil;
    [actionItem release];
    actionItem = nil;
    [loadingItem release];
    loadingItem = nil;
    
    loaded = NO;
    
    [super viewDidUnload];
}

- (void)performInitialLoadIfPossible {
    if (!loaded && source != nil) {
        loaded = YES;
        
        if (![source isLoaded]) {
            [self addStatusView:indicator];
            [source beginLoading];
        } else {
            [self finishedLoading];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self performInitialLoadIfPossible];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

AUTOROTATION_FOR_PAD_ONLY

@end
