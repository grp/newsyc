//
//  ComposeController.h
//  newsyc
//
//  Created by Grant Paul on 3/30/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"

#import "BarButtonItem.h"
#import "ActivityIndicatorItem.h"

@protocol ComposeControllerDelegate;
@class PlaceholderTextView;

@interface ComposeController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UITextViewDelegate, UITextFieldDelegate> {
    UITableView *tableView;
    NSArray *entryCells;
    PlaceholderTextView *textView;
    BarButtonItem *cancelItem;
    BarButtonItem *completeItem;
    ActivityIndicatorItem *loadingItem;
    BOOL keyboardVisible;
    __weak id<ComposeControllerDelegate> delegate;
}

@property (nonatomic, assign) id<ComposeControllerDelegate> delegate;

- (UITableViewCell *)generateTextFieldCell;
- (UITextField *)generateTextFieldForCell:(UITableViewCell *)cell;
- (UIResponder *)initialFirstResponder;

- (void)sendComplete;
- (void)sendFailed;
- (void)performSubmission;
- (BOOL)ableToSubmit;
- (void)textDidChange:(NSNotification *)notification;

@end

@protocol ComposeControllerDelegate <NSObject>
@optional

- (void)composeControllerDidSubmit:(ComposeController *)controller;
- (void)composeControllerDidCancel:(ComposeController *)controller;

@end

