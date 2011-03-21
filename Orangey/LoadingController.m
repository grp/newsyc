//
//  LoadingController.m
//  Orangey
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNKit.h"

#import "LoadingController.h"
#import "LoadingIndicatorView.h"

@implementation LoadingController
@synthesize source;

- (id)initWithSource:(HNObject *)source_ {
    if ((self = [super init])) {
        [self setSource:source_];
        [source_ setDelegate:self];
    }
    
    return self;
}

- (void)dealloc {
    [indicator release];
    if (![source isLoaded]) [source cancelLoading];
    [source setDelegate:nil];
    [source release];
    
    [super dealloc];
}

- (void)finishedLoading {
    // Overridden in subclasses.
}

- (void)showErrorWithTitle:(NSString *)title {
    [errorLabel setText:title];
    [[self view] addSubview:errorLabel];
    [errorLabel setFrame:[[self view] bounds]];
}

- (void)object:(HNObject *)source_ failedToLoadWithError:(NSError *)error {
    [self showErrorWithTitle:@"Error loading."];
}

- (void)objectFinishedLoading:(HNObject *)object; {
    [indicator removeFromSuperview];
    [self finishedLoading];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)index {
    if (index == [actionSheet cancelButtonIndex]) return;
    
    NSInteger first = [actionSheet firstOtherButtonIndex];
    if (index == first) {
        [[UIApplication sharedApplication] openURL:[source URL]];
    } else if (index == first + 1) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setURL:[source URL]];
        [pasteboard setString:[[source URL] absoluteString]];
    }
}

- (void)actionTapped {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Safari", @"Copy Link", nil];
    [sheet showInView:[[self tabBarController] view]];
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *action = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionTapped)];
    [[self navigationItem] setRightBarButtonItem:[action autorelease]];
}

- (void)viewDidUnload {
    [indicator release];
    indicator = nil;
    [errorLabel release];
    errorLabel = nil;
    
    loaded = NO;
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!loaded) {
        loaded = YES;
        
        if (![source isLoaded]) {
            [[self view] addSubview:indicator];
            [indicator setFrame:[[self view] bounds]];
            [source beginLoading];
        } else {
            [self finishedLoading];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

@end
