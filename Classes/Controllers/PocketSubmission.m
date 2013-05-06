//
//  PocketSubmission.m
//  newsyc
//
//  Created by Adam Bell on 2013-05-05.
//
//

#import "PocketSubmission.h"

@implementation PocketSubmission

- (id)initWithURL:(NSURL *)url_ {
    if (self = [super init]) {
        url = [url_ copy];
    }
    
    return self;
}

- (void)dealloc {
    [url release];
    
    [super dealloc];
}

- (void)submitPocketRequest {
    ProgressHUD *hud = [[ProgressHUD alloc] init];
    hud.text = @"Saving";
    [hud showInWindow:[[UIApplication sharedApplication] keyWindow]];
    [hud release];
    
    [self retain];
    
    [[PocketAPI sharedAPI] saveURL:url
                           handler:^(PocketAPI *api, NSURL *url, NSError *error) {
                               if (error) {
                                   [hud setText:@"Error Saving"];
                                   [hud setState:kProgressHUDStateError];
                                   [hud dismissAfterDelay:0.8f animated:YES];
                                   
                                   [self release];
                               } else {
                                   [hud setText:@"Saved!"];
                                   [hud setState:kProgressHUDStateCompleted];
                                   [hud dismissAfterDelay:0.8f animated:YES];
                                   
                                   [self release];
                               }
                           }];
}

- (UIViewController *)submitFromController:(UIViewController *)controller {
    if ([[PocketAPI sharedAPI] isLoggedIn]) {
        [self submitPocketRequest];
    } else {
        [[PocketAPI sharedAPI] loginWithHandler:^(PocketAPI *api, NSError *error) {
            [self submitPocketRequest];
        }];
    }
    
    return nil;
}

@end
