//
//  LoginController.h
//  Orangey
//
//  Created by Grant Paul on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNKit.h"

@interface LoginController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, HNSessionAuthenticatorDelegate> {
    UITableView *tableView;
    UITableViewCell *usernameCell;
    UITextField *usernameField;
    UITableViewCell *passwordCell;
    UITextField *passwordField;
    UIBarButtonItem *cancelItem;
    UIBarButtonItem *completeItem;
    UIBarButtonItem *loadingItem;
    HNSessionAuthenticator *authenticator;
}

@end
