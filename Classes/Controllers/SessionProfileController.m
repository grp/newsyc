//
//  SessionProfileController.m
//  newsyc
//
//  Created by Grant Paul on 3/29/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "UIActionSheet+Context.h"

#import "SessionProfileController.h"
#import "LoginController.h"
#import "HackerNewsLoginController.h"
#import "NavigationController.h"
#import "PlacardButton.h"
#import "SubmissionListController.h"

@implementation SessionProfileController

- (void)dealloc {
    [loginContainer release];
    [loginButton release];
    [loginImage release];
    [logoutItem release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHNSessionChangedNotification object:nil];
    
    [super dealloc];
}

- (void)setSource:(HNObject *)source_ {
    [super setSource:source_];
    
    [loginContainer setHidden:(source != nil)];
    if (isVisible) [[[self tabBarController] navigationItem] setLeftBarButtonItem:(source != nil ? logoutItem : nil)];
}

- (void)logout {
    [HNSession setCurrentSession:nil];
}

- (void)logoutPressed {
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    [sheet addButtonWithTitle:@"Logout"];
    [sheet addButtonWithTitle:@"Cancel"];
    [sheet setCancelButtonIndex:1];
    [sheet setDestructiveButtonIndex:0];
    [sheet setDelegate:self];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [sheet showFromBarButtonItem:logoutItem animated:YES];
    else [sheet showInView:[[self view] window]];
    [sheet setSheetContext:@"logout"];
    [sheet release];
}

- (void)actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(NSInteger)index {
    if ([[sheet sheetContext] isEqual:@"logout"]) {
        if (index == [sheet destructiveButtonIndex]) {
            [self logout];
        }
    } else {
        if ([[[self class] superclass] instancesRespondToSelector:@selector(actionSheet:clickedButtonAtIndex:)])
            [super actionSheet:sheet clickedButtonAtIndex:index];
    }
}

- (void)loginControllerDidLogin:(LoginController *)controller {
    [[self tabBarController] dismissModalViewControllerAnimated:YES];
}

- (void)loginControllerDidCancel:(LoginController *)controller {
    [[self tabBarController] dismissModalViewControllerAnimated:YES];
}

- (void)_loginPressed {
    LoginController *login = [[HackerNewsLoginController alloc] init];
    [login setDelegate:self];
    NavigationController *navigation = [[NavigationController alloc] initWithRootViewController:[login autorelease]];
    [[self tabBarController] presentModalViewController:[navigation autorelease] animated:YES];
}

- (void)sessionChangedWithNotification:(NSNotification *)notification {
    HNSession *session = [notification object];
    HNUser *user = [session user];
    [self setSource:user];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setSource:[[HNSession currentSession] user]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionChangedWithNotification:) name:kHNSessionChangedNotification object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];

    [loginButton release];
    loginButton = nil;
    [loginContainer release];
    loginContainer = nil;
    [loginImage release];
    loginImage = nil;
    [logoutItem release];
    logoutItem = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHNSessionChangedNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];    	
	
    // XXX: because this navigation item is shown for every tab, this is a gigantic hack:
    // we are removing it and adding it manually as this view is shown/hidden :(
    // maybe this should be a button in the table view instead?
    [[[self tabBarController] navigationItem] setLeftBarButtonItem:(source != nil ? logoutItem : nil)];
    
    isVisible = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[[self tabBarController] navigationItem] setLeftBarButtonItem:nil];
    
    isVisible = NO;
}

- (int)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    if (section == 1) return [super tableView:table numberOfRowsInSection:section] + 1;
    else return [super tableView:table numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 1 && [indexPath row] == [tableView numberOfRowsInSection:[indexPath section]] - 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        [[cell textLabel] setText:@"Saved"];
        
        return [cell autorelease];
    } else {
        return [super tableView:table cellForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 1 && [indexPath row] == [tableView numberOfRowsInSection:[indexPath section]] - 1) {
        HNEntryList *list = [HNEntryList entryListWithIdentifier:kHNEntryListIdentifierSaved user:(HNUser *) source];
        
        SubmissionListController *controller = [[SubmissionListController alloc] initWithSource:list];
        [controller setTitle:@"Saved"];
        [[self navigationController] pushViewController:[controller autorelease] animated:YES];
    } else {
        [super tableView:table didSelectRowAtIndexPath:indexPath];
    }
}

- (void)loadView {
    [super loadView];
    
    loginContainer = [[UIView alloc] initWithFrame:[[self view] bounds]];
    [loginContainer setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [loginContainer setBackgroundColor:[UIColor whiteColor]];
    [[self view] addSubview:loginContainer];
    
    CGRect buttonFrame;
    buttonFrame.size.width = [[self view] bounds].size.width / 2;
    buttonFrame.size.height = 44.0f;
    buttonFrame.origin.x = ([[self view] bounds].size.width / 2) - (buttonFrame.size.width / 2);
    buttonFrame.origin.y = ([[self view] bounds].size.height / 2) - (buttonFrame.size.height / 2) + 120.0f;
    loginButton = [[PlacardButton alloc] initWithFrame:buttonFrame];
    [loginButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(_loginPressed) forControlEvents:UIControlEventTouchUpInside];
    [loginContainer addSubview:loginButton];
    
    UIImage *image = [UIImage imageNamed:@"empty.png"];
    CGRect imageFrame;
    imageFrame.size.width = [image size].width;
    imageFrame.size.height = [image size].height;
    imageFrame.origin.x = ([[self view] bounds].size.width / 2) - (imageFrame.size.width / 2);
    imageFrame.origin.y = ([[self view] bounds].size.height / 2) - (imageFrame.size.height / 2) - 60.0f;
    loginImage = [[UIImageView alloc] initWithFrame:imageFrame];
    [loginImage setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [loginImage setImage:image];
    [loginContainer addSubview:loginImage];
    
    logoutItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutPressed)];
    
    [[[self tabBarController] navigationItem] setLeftBarButtonItem:source != nil ? logoutItem : nil];
    [loginContainer setHidden:source != nil];
}

AUTOROTATION_FOR_PAD_ONLY

@end
