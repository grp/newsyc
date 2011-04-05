//
//  ComposeController.h
//  newsyc
//
//  Created by Grant Paul on 3/30/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"

@class PlaceholderTextView;
@interface ComposeController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UITextViewDelegate, UITextFieldDelegate> {
    UITableView *tableView;
    NSArray *entryCells;
    PlaceholderTextView *textView;
    UIBarButtonItem *cancelItem;
    UIBarButtonItem *completeItem;
    UIBarButtonItem *loadingItem;
    BOOL keyboardVisible;
    id delegate;
}

@property (nonatomic, assign) id delegate;

- (UITableViewCell *)generateTextFieldCell;
- (UITextField *)generateTextFieldForCell:(UITableViewCell *)cell;
- (UIResponder *)initialFirstResponder;

- (void)sendComplete;
- (void)sendFailed;
- (void)performSubmission;

@end
