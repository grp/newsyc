//
//  LoginController.h
//  newsyc
//
//  Created by Grant Paul on 3/22/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"

@protocol LoginControllerDelegate;

@interface LoginController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, HNSessionAuthenticatorDelegate> {
    UIImageView *backgroundImageView;
    UITableView *tableView;
    UITableViewCell *usernameCell;
    UITextField *usernameField;
    UITableViewCell *passwordCell;
    UITextField *passwordField;
    UIBarButtonItem *cancelItem;
    UIBarButtonItem *completeItem;
    UIBarButtonItem *loadingItem;
    HNSessionAuthenticator *authenticator;
    id<LoginControllerDelegate> delegate;
}

@property (nonatomic, assign) id<LoginControllerDelegate> delegate;

@end

@protocol LoginControllerDelegate<NSObject>
@optional

- (void)loginControllerDidLogin:(LoginController *)controller;
- (void)loginControllerDidCancel:(LoginController *)controller;

@end
