//
//  ComposeController.m
//  newsyc
//
//  Created by Grant Paul on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ComposeController.h"
#import "UIActionSheet+Context.h"
#import "HNKit.h"
#import "PlaceholderTextView.h"

@implementation ComposeController
@synthesize delegate;

- (void)dealloc {
    [tableView release];
    [completeItem release];
    [cancelItem release];
    [loadingItem release];
    
    [super dealloc];
}

- (void)close {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)hasText {
    return [[textView text] length] > 0;
}

- (void)actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(NSInteger)index {
    if ([[sheet sheetContext] isEqual:@"cancel"]) {
        if (index == [sheet cancelButtonIndex]) return;
        
        [self close];
    }
}

- (void)cancel {
    if (![self hasText]) {
        [self close];
    } else {
        UIActionSheet *sheet = [[UIActionSheet alloc] init];
        [sheet addButtonWithTitle:@"Discard"];
        [sheet addButtonWithTitle:@"Cancel"];
        [sheet setDestructiveButtonIndex:0];
        [sheet setCancelButtonIndex:1];
        [sheet setSheetContext:@"cancel"];
        [sheet setDelegate:self];
        [sheet showInView:[[self view] window]];
        [sheet release];
    }
}

- (void)_sendFinished {
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

- (void)sendComplete {
    [self _sendFinished];
    
    [self close];
}

- (void)sendFailed {
    [self _sendFinished];
    
    [[self navigationItem] setRightBarButtonItem:completeItem];
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Error Posting"];
    [alert setMessage:@"Unable to post. Ensure you have a data connection and can perform this post."];
    [alert addButtonWithTitle:@"Continue"];
    [alert show];
    [alert release];
}

- (void)performSubmission {
    // Overridden in subclasses.
}

- (void)send {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [[self navigationItem] setRightBarButtonItem:loadingItem];
    
    [self performSubmission];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [entryCells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [entryCells objectAtIndex:[indexPath row]];
}

- (UITableViewCell *)generateTextFieldCell {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [[cell textLabel] setTextColor:[UIColor darkGrayColor]];
    [[cell textLabel] setFont:[UIFont systemFontOfSize:16.0f]];
    return [cell autorelease];
}

- (UITextField *)generateTextFieldForCell:(UITableViewCell *)cell {
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(0, 11, 295, 30)];
    [field setAdjustsFontSizeToFitWidth:YES];
    [field setTextColor:[UIColor blackColor]];
    [field setDelegate:self];
    [field setBackgroundColor:[UIColor whiteColor]];
    [field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [field setTextAlignment:UITextAlignmentLeft];
    [field setEnabled:YES];
    
    CGSize label = [[[cell textLabel] text] sizeWithFont:[[cell textLabel] font]];
    CGRect frame = [field frame];
    frame.origin.x = 10.0f + label.width + 10.0f;
    frame.size.width -= label.width + 10.0f;
    [field setFrame:frame];
    
    return [field autorelease];
}

- (UITableViewCell *)entryInputCellWithTitle:(NSString *)title {
    UITableViewCell *cell = [self generateTextFieldCell];
    [[cell textLabel] setText:title];
    UITextField *field = [self generateTextFieldForCell:cell];
    [cell addSubview:field];
    return cell;
}

- (BOOL)includeMultilineEditor {
    return YES;
}

- (NSString *)multilinePlaceholder {
    return nil;
}

- (NSArray *)inputEntryCells {
    return [NSArray array];
}

- (void)scrollToBottom {
    [tableView setContentOffset:CGPointMake(0, [tableView contentSize].height - [tableView bounds].size.height) animated:NO];
}

- (void)updateTextViewHeight {
    UITableViewCell *last = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:([entryCells count] - 1) inSection:0]];
    CGFloat offset = [last frame].origin.y + [last bounds].size.height;
    CGFloat minimum = [tableView bounds].size.height - offset;
    
    CGRect frame = [textView frame];
    frame.size.height = [textView contentSize].height;
    if (frame.size.height < minimum) frame.size.height = minimum;
    [textView setFrame:frame];
}

- (void)textViewDidChange:(UITextView *)textView_ {
    [self updateTextViewHeight];
    
    // Since our UITextView isn't managing it's own scrolling,
    // it doesn't know to scroll if you are typing at the end.
    // Instead, we need to scroll the table view ourself.
    NSRange selected = [textView selectedRange];
    if (selected.location == [[textView text] length]) {
        // XXX: find out why this needs to be done on the next runloop cycle to work
        [self performSelector:@selector(scrollToBottom) withObject:nil afterDelay:0.0f];
    }
    
    if ([self includeMultilineEditor]) [tableView setTableFooterView:textView];
}

- (void)loadView {
    [super loadView];
    
    // Match background color in case the keyboard animation is
    // slightly off, and you would otherwise see an ugly black
    // background behind the keyboard.
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
    entryCells = [[self inputEntryCells] retain];
    
    textView = [[PlaceholderTextView alloc] initWithFrame:CGRectMake(0, 0, [[self view] bounds].size.width, 0)];
    [textView setDelegate:self];
    [textView setScrollEnabled:NO];
    [textView setEditable:YES];
    [textView setPlaceholder:[self multilinePlaceholder]];
    [textView setFont:[UIFont systemFontOfSize:16.0f]];
    
    tableView = [[UITableView alloc] initWithFrame:[[self view] bounds] style:UITableViewStylePlain];
    [tableView setAllowsSelection:NO];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    if ([self includeMultilineEditor]) [tableView setTableFooterView:textView];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [[self view] addSubview:tableView];
    
    completeItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(send)];
    cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner sizeToFit];
    [spinner startAnimating];
    [spinner setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
    loadingItem = [[UIBarButtonItem alloc] initWithCustomView:[spinner autorelease]];
    
    // Make sure that the text view's height is setup properly.
    // (Reloading is needed to force the cells to be initialized.)
    [tableView reloadData];
    [self updateTextViewHeight];
}

- (NSString *)title {
    return @"Compose";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:[[self view] window]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:[[self view] window]];
    
    [[self navigationItem] setRightBarButtonItem:completeItem];
    [[self navigationItem] setLeftBarButtonItem:cancelItem];
    
    [self setTitle:[self title]];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:[[self view] window]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:[[self view] window]];
    
    [[self navigationItem] setLeftBarButtonItem:nil];
    [[self navigationItem] setRightBarButtonItem:nil];
    
    [tableView release];
    tableView = nil;
    [loadingItem release];
    loadingItem = nil;
    [cancelItem release];
    cancelItem = nil;
    [completeItem release];
    completeItem = nil;
    [entryCells release];
    entryCells = nil;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (!keyboardVisible) return;
    
    NSDictionary *info = [notification userInfo];
    NSValue *boundsValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSNumber *curve = [info objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSNumber *duration = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGSize keyboardSize = [boundsValue CGRectValue].size;
    
    CGRect frame = [tableView frame];
    frame.size.height += keyboardSize.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDuration:[duration floatValue]];
    [tableView setFrame:frame];
    [UIView commitAnimations];
    
    keyboardVisible = NO;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (keyboardVisible) return;
    
    NSDictionary *info = [notification userInfo];
    NSValue *boundsValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSNumber *curve = [info objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSNumber *duration = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGSize keyboardSize = [boundsValue CGRectValue].size;
    
    CGRect frame = [tableView frame];
    frame.size.height -= keyboardSize.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDuration:[duration floatValue]];
    [tableView setFrame:frame];
    [UIView commitAnimations];
    
    keyboardVisible = NO;
}

- (UIResponder *)initialFirstResponder {
    return nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    [[self initialFirstResponder] becomeFirstResponder];
}

@end
