//
//  InstapaperLoginController.m
//  newsyc
//
//  Created by Alex Galonsky on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InstapaperLoginController.h"
#import "InstapaperAPI.h"


@implementation InstapaperLoginController

- (id) init {
    self = [super init];
    loginTitle = @"Instapaper";
    return self;
}

- (void)complete {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [[self navigationItem] setRightBarButtonItem:loadingItem];
    [[InstapaperAPI sharedInstance] setUsername:[usernameField text]];
    [[InstapaperAPI sharedInstance] setPassword:[passwordField text]];
    [[InstapaperAPI sharedInstance] addItemWithURL:[[InstapaperAPI sharedInstance] lastURL]];
    
    [[self navigationItem] setRightBarButtonItem:nil];
    
    if ([delegate respondsToSelector:@selector(loginControllerDidLogin:)])
        [delegate loginControllerDidLogin:self];
}

@end
