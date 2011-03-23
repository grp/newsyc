//
//  LoginController.m
//  Orangey
//
//  Created by Grant Paul on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginController.h"

#import "HNKit.h"

@implementation LoginController

- (void)dealloc {
    [tableView release];
    [usernameCell release];
    [passwordCell release];
    
    [super dealloc];
}

- (void)_updateCompleteItem {
    if ([[usernameField text] length] > 0 && [[passwordField text] length] > 0) {
        [completeItem setEnabled:YES];
    } else {
        [completeItem setEnabled:NO];
    }
}

- (UITextField *)_createCellTextField {
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(120, 10, 175, 30)];
    [field setAdjustsFontSizeToFitWidth:YES];
    [field setTextColor:[UIColor blackColor]];
    [field setDelegate:self];
    [field setBackgroundColor:[UIColor whiteColor]];
    [field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [field setTextAlignment:UITextAlignmentLeft];
    [field setEnabled:YES];
    return [field autorelease];
}

- (void)loadView {
    [super loadView];
    
    tableView = [[UITableView alloc] initWithFrame:[[self view] bounds] style:UITableViewStyleGrouped];
    
    [tableView setBackgroundColor:[UIColor colorWithHue:0.044f saturation:0.74f brightness:1.0f alpha:1.0f]];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setScrollEnabled:NO];
    [tableView setAllowsSelection:NO];
    [[self view] addSubview:tableView];
    
    usernameCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [[usernameCell textLabel] setText:@"Username"];
    usernameField = [self _createCellTextField];
    [usernameField setReturnKeyType:UIReturnKeyNext];
    [usernameCell addSubview:usernameField];
    
    passwordCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [[passwordCell textLabel] setText:@"Password"];
    passwordField = [self _createCellTextField];
    [passwordField setSecureTextEntry:YES];
    [passwordField setReturnKeyType:UIReturnKeyDone];
    [passwordCell addSubview:passwordField];
    
    completeItem = [[UIBarButtonItem alloc] initWithTitle:@"Confirm" style:UIBarButtonItemStyleBordered target:self action:@selector(complete)];
    cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner sizeToFit];
    [spinner startAnimating];
    [spinner setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
    loadingItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationItem] setRightBarButtonItem:completeItem];
    [[self navigationItem] setLeftBarButtonItem:cancelItem];
    [self _updateCompleteItem];
    
    [self setTitle:@"Login"];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [passwordCell release];
    passwordCell = nil;
    [usernameCell release];
    usernameCell = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [usernameField becomeFirstResponder];
}

- (void)cancel {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)sessionAuthenticator:(HNSessionAuthenticator *)authenticator didRecieveToken:(HNSessionToken)token {
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    HNSession *session = [[HNSession alloc] initWithUsername:[usernameField text] token:token];
    [HNSession setCurrentSession:[session autorelease]];
    
    [[self navigationItem] setRightBarButtonItem:nil];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)sessionAuthenticatorDidRecieveFailure:(HNSessionAuthenticator *)authenticator {
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Unable to Authenticate"];
    [alert setMessage:@"Unable to authenticate with Hacker News."];
    [alert addButtonWithTitle:@"Continue"];
    [alert setCancelButtonIndex:0];
    [alert show];
    [alert release];
    
    [[self navigationItem] setRightBarButtonItem:completeItem];
}

- (void)complete {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [[self navigationItem] setRightBarButtonItem:loadingItem];
    
    authenticator = [[HNSessionAuthenticator alloc] initWithUsername:[usernameField text] password:[passwordField text]];
    [authenticator setDelegate:self];
    [authenticator beginAuthenticationRequest];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == usernameField) {
        [passwordField becomeFirstResponder];
    } else if (textField == passwordField) {
        [self complete];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self performSelector:@selector(_updateCompleteItem) withObject:nil afterDelay:0.0f];
    
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 2;
        default: return 0;
    }
}

- (CGFloat)tableView:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] == 0) {
        return usernameCell;
    } else if ([indexPath row] == 1) {
        return passwordCell;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 65.0f;
    } else {
        return 0.0f;
    }
}

- (UIView *)tableView:(UITableView *)table viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [tableView bounds].size.width, 40.0f)];
        [label setText:@"Hacker News"];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin];
        [label setTextAlignment:UITextAlignmentCenter];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setShadowColor:[UIColor blackColor]];
        [label setShadowOffset:CGSizeMake(0, 1.0f)];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont boldSystemFontOfSize:30.0f]];
        return [label autorelease];
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 42.0f;
    } else {
        return 0.0f;
    }
}

- (UIView *)tableView:(UITableView *)table viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [tableView bounds].size.width, 15.0f)];
        [label setText:@"Your info is only shared with Hacker News."];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin];
        [label setTextAlignment:UITextAlignmentCenter];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont systemFontOfSize:14.0f]];
        return [label autorelease];
    } else {
        return nil;
    }
}

@end