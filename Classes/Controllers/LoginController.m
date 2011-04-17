//
//  LoginController.m
//  newsyc
//
//  Created by Grant Paul on 3/22/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "LoginController.h"

@implementation LoginController
@synthesize delegate;

- (void)dealloc {
    [tableView release];
    [usernameCell release];
    [passwordCell release];
    [backgroundImageView release];
    [topLabel release];
    [bottomLabel release];
    
    [super dealloc];
}

- (id)init {
    if ((self = [super init])) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [self setModalPresentationStyle:UIModalPresentationFormSheet];
    }
    
    return self;
}

- (BOOL)requiresPassword {
    return YES;
}

- (void)_updateCompleteItem {
    if (([[usernameField text] length] > 0 && [[passwordField text] length] > 0) || ![self requiresPassword]) {
        [completeItem setEnabled:YES];
    } else {
        [completeItem setEnabled:NO];
    }
}

- (UITextField *)_createCellTextField {
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectZero];
    [field setAdjustsFontSizeToFitWidth:YES];
    [field setTextColor:[UIColor blackColor]];
    [field setDelegate:self];
    [field setBackgroundColor:[UIColor clearColor]];
    [field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [field setTextAlignment:UITextAlignmentLeft];
    [field setEnabled:YES];
    [field setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    return [field autorelease];
}

- (NSArray *)gradientColors {
    return nil;
}

- (void)loadView {
    [super loadView];
    
    // XXX: this is one particuarly ugly way of making a gradient :(
    UIGraphicsBeginImageContext([[self view] bounds].size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(rgb, (CFArrayRef) [self gradientColors], NULL);
    CGContextDrawRadialGradient(context, gradient, CGPointMake(160.0f, 110.0f), 5.0f, CGPointMake(160.0f, 110.0f), 1500.0f, kCGGradientDrawsBeforeStartLocation);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(rgb);
	UIImage *background = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    tableView = [[UITableView alloc] initWithFrame:[[self view] bounds] style:UITableViewStyleGrouped];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setScrollEnabled:NO];
    [tableView setAllowsSelection:NO];
    [[self view] addSubview:tableView];
    
    backgroundImageView = [[UIImageView alloc] initWithFrame:[[self view] bounds]];
    [backgroundImageView setImage:background];
    [backgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        tableView.backgroundView = backgroundImageView;
    else
        [[self view] insertSubview:backgroundImageView atIndex:0];
    
    usernameCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [[usernameCell textLabel] setText:@"Username"];
    usernameField = [self _createCellTextField];
    usernameField.frame = CGRectMake(115, 12, usernameCell.bounds.size.width - 125, 30);
    [usernameField setReturnKeyType:UIReturnKeyNext];
    [usernameCell addSubview:usernameField];
    
    passwordCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [[passwordCell textLabel] setText:@"Password"];
    passwordField = [self _createCellTextField];
    passwordField.frame = CGRectMake(115, 12, passwordCell.bounds.size.width - 125, 30);
    [passwordField setSecureTextEntry:YES];
    [passwordField setReturnKeyType:UIReturnKeyDone];
    [passwordCell addSubview:passwordField];
    
    completeItem = [[UIBarButtonItem alloc] initWithTitle:@"Confirm" style:UIBarButtonItemStyleBordered target:self action:@selector(_authenticate)];
    cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    
    bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [tableView bounds].size.width, 15.0f)];
    [bottomLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin];
    [bottomLabel setTextAlignment:UITextAlignmentCenter];
    [bottomLabel setBackgroundColor:[UIColor clearColor]];
    [bottomLabel setFont:[UIFont systemFontOfSize:14.0f]];
    
    topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [tableView bounds].size.width, 40.0f)];
    [topLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin];
    [topLabel setTextAlignment:UITextAlignmentCenter];
    [topLabel setBackgroundColor:[UIColor clearColor]];
    [topLabel setShadowColor:[UIColor blackColor]];
    [topLabel setShadowOffset:CGSizeMake(0, 1.0f)];
    [topLabel setFont:[UIFont boldSystemFontOfSize:30.0f]];
    
    loadingItem = [[ActivityIndicatorItem alloc] initWithSize:kActivityIndicatorItemStandardSize];
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

- (void)finish {
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

- (void)fail {
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Unable to Authenticate"];
    [alert setMessage:@"Unable to authenticate. Make sure your username and password are correct."];
    [alert addButtonWithTitle:@"Continue"];
    [alert setCancelButtonIndex:0];
    [alert show];
    [alert release];
    
    [[self navigationItem] setRightBarButtonItem:completeItem];
}

- (void)succeed {
    [[self navigationItem] setRightBarButtonItem:nil];
    
    if ([delegate respondsToSelector:@selector(loginControllerDidLogin:)])
        [delegate loginControllerDidLogin:self];
}

- (void)cancel {
    if ([delegate respondsToSelector:@selector(loginControllerDidCancel:)])
        [delegate loginControllerDidCancel:self];
}

- (void)authenticate {
    // overridden in subclasses
}

- (void)_authenticate {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [[self navigationItem] setRightBarButtonItem:loadingItem];
    [self authenticate];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == usernameField) {
        [passwordField becomeFirstResponder];
    } else if (textField == passwordField) {
        [self _authenticate];
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
        return topLabel;
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
        return bottomLabel;
    } else {
        return nil;
    }
}

AUTOROTATION_FOR_PAD_ONLY

@end