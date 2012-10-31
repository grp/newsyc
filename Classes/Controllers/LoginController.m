//
//  LoginController.m
//  newsyc
//
//  Created by Grant Paul on 3/22/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "LoginController.h"
#import "LoadingIndicatorView.h"

@implementation LoginController
@synthesize delegate;

- (void)dealloc {
    [tableView release];
	[loadingCell release];
    [usernameCell release];
    [passwordCell release];
    [backgroundImageView release];
    [topLabel release];
    [bottomLabel release];
    [cancelItem release];
    [completeItem release];
    [loadingItem release];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];

    [super dealloc];
}

- (id)init {
    if ((self = [super init])) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
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

    backgroundImageView = [[UIImageView alloc] initWithFrame:[[self view] bounds]];
    [backgroundImageView setImage:background];
    [backgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [[self view] addSubview:backgroundImageView];

    CGRect centeringAlignmentFrame = CGRectMake(0, 0, [[self view] bounds].size.width, [[self view] bounds].size.height - 80.0f);
    centeringAlignmentView = [[UIView alloc] initWithFrame:centeringAlignmentFrame];
    [centeringAlignmentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [[self view] addSubview:centeringAlignmentView];

    tableContainerView = [[UIView alloc] initWithFrame:[centeringAlignmentView bounds]];
    [tableContainerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [centeringAlignmentView addSubview:tableContainerView];

    tableView = [[UITableView alloc] initWithFrame:[tableContainerView bounds] style:UITableViewStyleGrouped];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setBackgroundView:[[[UIView alloc] init] autorelease]];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setScrollEnabled:NO];
    [tableView setAllowsSelection:NO];
    [tableContainerView addSubview:tableView];
    
    // XXX: this is a hack. really, this should calculate the positioning.
    CGRect fieldRect = CGRectMake(115, 12, -135, 30);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        fieldRect = CGRectMake(135, 12, -175, 30);
    
    usernameCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [[usernameCell textLabel] setText:@"Username"];
    usernameField = [self _createCellTextField];
    usernameField.frame = CGRectMake(fieldRect.origin.x, fieldRect.origin.y, usernameCell.bounds.size.width + fieldRect.size.width, fieldRect.size.height);
    [usernameField setReturnKeyType:UIReturnKeyNext];
    [usernameCell addSubview:usernameField];
    
    passwordCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [[passwordCell textLabel] setText:@"Password"];
    passwordField = [self _createCellTextField];
    passwordField.frame = CGRectMake(fieldRect.origin.x, fieldRect.origin.y, passwordCell.bounds.size.width + fieldRect.size.width, fieldRect.size.height);
    [passwordField setSecureTextEntry:YES];
    [passwordField setReturnKeyType:UIReturnKeyDone];
    [passwordCell addSubview:passwordField];
    
	loadingCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    LoadingIndicatorView *loadingIndicatorView = [[LoadingIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    [loadingIndicatorView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
    [loadingIndicatorView setCenter:[loadingCell center]];
	[loadingCell addSubview:[loadingIndicatorView autorelease]];
		
    bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [tableView bounds].size.width, 15.0f)];
    [bottomLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin];
    [bottomLabel setTextAlignment:UITextAlignmentCenter];
    [bottomLabel setBackgroundColor:[UIColor clearColor]];
    [bottomLabel setFont:[UIFont systemFontOfSize:14.0f]];
    
    topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [tableView bounds].size.width, 40.0f)];
    [topLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin];
    [topLabel setTextAlignment:UITextAlignmentCenter];
    [topLabel setBackgroundColor:[UIColor clearColor]];
    [topLabel setShadowColor:[UIColor clearColor]];
    [topLabel setShadowOffset:CGSizeMake(0, 1.0f)];
    [topLabel setFont:[UIFont boldSystemFontOfSize:30.0f]];

    [tableView layoutIfNeeded];
    CGFloat tableViewHeight = [tableView contentSize].height;
    [tableView setFrame:CGRectMake(0, floorf((tableContainerView.bounds.size.height - tableViewHeight) / 2), tableContainerView.bounds.size.width, tableViewHeight)];

    completeItem = [[BarButtonItem alloc] initWithTitle:@"Confirm" style:UIBarButtonItemStyleBordered target:self action:@selector(_authenticate)];
    cancelItem = [[BarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];

	loadingItem = [[ActivityIndicatorItem alloc] initWithSize:kActivityIndicatorItemStandardSize];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationItem] setRightBarButtonItem:completeItem];
    [[self navigationItem] setLeftBarButtonItem:cancelItem];
    [self _updateCompleteItem];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideWithNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowWithNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrameWithNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];

    [self setTitle:@"Login"];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	
    [loadingCell release];
	loadingCell = nil;
    [passwordCell release];
    passwordCell = nil;
    [usernameCell release];
    usernameCell = nil;
    [loadingItem release];
    loadingItem = nil;
    [cancelItem release];
    cancelItem = nil;
    [completeItem release];
    completeItem = nil;
    [topLabel release];
    topLabel = nil;
    [bottomLabel release];
    bottomLabel = nil;
    [backgroundImageView release];
    backgroundImageView = nil;
    [tableView release];
    tableView = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
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
	
	isAuthenticating = NO;
	[tableView reloadData];
    [passwordField becomeFirstResponder];
    [[self navigationItem] setRightBarButtonItem:completeItem];
}

- (void)succeed {
    [[self navigationItem] setRightBarButtonItem:nil];
    
    if ([delegate respondsToSelector:@selector(loginControllerDidLogin:)]) {
        [delegate loginControllerDidLogin:self];
    }
}

- (void)cancel {
    if ([delegate respondsToSelector:@selector(loginControllerDidCancel:)]) {
        [delegate loginControllerDidCancel:self];
    }
}

- (void)authenticate {
    // overridden in subclasses
	isAuthenticating = YES;
	[tableView reloadData];
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
        case 0: return isAuthenticating ? 1 : 2;
        default: return 0;
    }
}

- (CGFloat)tableView:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return isAuthenticating ? 88.0 : 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] == 0) {		
        return isAuthenticating ? loadingCell : usernameCell;
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

- (void)updateForKeyboardNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];

    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect endingFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect windowEndingFrame = [[centeringAlignmentView window] convertRect:endingFrame fromWindow:nil];
    CGRect viewEndingFrame = [centeringAlignmentView convertRect:windowEndingFrame fromView:nil];

    CGRect viewFrame = [centeringAlignmentView bounds];
    CGRect endingIntersectionRect = CGRectIntersection(viewFrame, viewEndingFrame);
    viewFrame.size.height -= endingIntersectionRect.size.height;

    [UIView animateWithDuration:duration delay:0 options:(curve << 16) animations:^{
        [tableContainerView setFrame:viewFrame];
    } completion:NULL];
}

- (void)keyboardWillHideWithNotification:(NSNotification *)notification {
    [self updateForKeyboardNotification:notification];
}

- (void)keyboardWillShowWithNotification:(NSNotification *)notification {
    [self updateForKeyboardNotification:notification];
}

- (void)keyboardWillChangeFrameWithNotification:(NSNotification *)notification {
    [self updateForKeyboardNotification:notification];
}

AUTOROTATION_FOR_PAD_ONLY

@end