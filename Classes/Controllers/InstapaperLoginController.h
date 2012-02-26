//
//  InstapaperLoginController.h
//  newsyc
//
//  Created by Alex Galonsky on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginController.h"
#import "InstapaperAuthenticator.h"

@interface InstapaperLoginController : LoginController <LoginControllerDelegate, InstapaperAuthenticatorDelegate> {
    NSURL *pendingURL;
}

@property (nonatomic, copy) NSURL *pendingURL;

@end
