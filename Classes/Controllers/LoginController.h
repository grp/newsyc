//
//  LoginController.h
//  newsyc
//
//  Created by Grant Paul on 3/22/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "BarButtonItem.h"
#import "ActivityIndicatorItem.h"

@protocol LoginControllerDelegate;

@interface LoginController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    UIImageView *backgroundImageView;
    UITableView *tableView;
	UITableViewCell *loadingCell;
    UITableViewCell *usernameCell;
    UITextField *usernameField;
    UITableViewCell *passwordCell;
    UITextField *passwordField;
    BarButtonItem *cancelItem;
    BarButtonItem *completeItem;
    ActivityIndicatorItem *loadingItem;
    __weak id<LoginControllerDelegate> delegate;
    UILabel *topLabel;
    UILabel *bottomLabel;
	
	BOOL isAuthenticating;
}

@property (nonatomic, assign) id<LoginControllerDelegate> delegate;

- (void)finish;
- (void)authenticate;

- (void)fail;
- (void)succeed;
- (void)cancel;

@end

@protocol LoginControllerDelegate<NSObject>
@optional

- (void)loginControllerDidLogin:(LoginController *)controller;
- (void)loginControllerDidCancel:(LoginController *)controller;

@end
