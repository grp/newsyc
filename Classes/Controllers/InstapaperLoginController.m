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

- (id) initWithMessage:(NSString *)message {
    self = [super init];
    loginTitle = @"Instapaper";
    bottomText = message;
    return self;
}

- (void)complete {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [[self navigationItem] setRightBarButtonItem:loadingItem];
    [[InstapaperAPI sharedInstance] setUsername:[usernameField text]];
    [[InstapaperAPI sharedInstance] setPassword:[passwordField text]];
    [[InstapaperAPI sharedInstance] addItemWithURL:[[InstapaperAPI sharedInstance] lastURL]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[usernameField text] forKey:@"instapaper-username"];
    [defaults setObject:[passwordField text] forKey:@"instapaper-password"];
    
    [[self navigationItem] setRightBarButtonItem:nil];
    
    if ([delegate respondsToSelector:@selector(loginControllerDidLogin:)])
        [delegate loginControllerDidLogin:self];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

@end
