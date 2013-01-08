//
//  PocketSubmission.m
//  newsyc
//
//  Created by Joseph Fabisevich on 1/6/13.
//
//

#import "PocketSubmission.h"

@implementation PocketSubmission

- (id)initWithURL:(NSURL *)submissionURL
{
    if (self == [super init]) {
        hud = [[ProgressHUD alloc] init];
        url = submissionURL;
        
        [self setup];
    }
    
    return self;
}

- (void)dealloc
{
    [hud release];
    [super dealloc];
}

- (void)setup
{
    [PocketAPI sharedAPI].consumerKey = POCKET_CONSUMER_KEY;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Pocket Requests

- (void)submitPocketRequest
{
    if ([[PocketAPI sharedAPI] isLoggedIn]) {
        [self saveArticleToPocket];
    } else {
        [self loginToPocket];
    }
}

- (void)loginToPocket
{
    [[PocketAPI sharedAPI] loginWithDelegate:self];
}

- (void)saveArticleToPocket
{
    [[PocketAPI sharedAPI] saveURL:url delegate:self];
    [hud setText:@"Saving"];
    [hud showInWindow:[[UIApplication sharedApplication] keyWindow]];
    [hud release];    
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delegation - Pocket API stuffs

-(void)pocketAPILoggedIn:(PocketAPI *)api
{
    [hud setText:@"Logged In!"];
    [hud setState:kProgressHUDStateCompleted];
    [hud dismissAfterDelay:0.8f animated:YES];
}

-(void)pocketAPI:(PocketAPI *)api hadLoginError:(NSError *)error
{
    [hud setText:@"Couldn't Log In :("];
    [hud setState:kProgressHUDStateError];
    [hud dismissAfterDelay:0.8f animated:YES];
}

-(void)pocketAPI:(PocketAPI *)api savedURL:(NSURL *)url
{
    [hud setText:@"Saved!"];
    [hud setState:kProgressHUDStateCompleted];
    [hud dismissAfterDelay:0.8f animated:YES];
}

-(void)pocketAPI:(PocketAPI *)api failedToSaveURL:(NSURL *)url error:(NSError *)error
{
    [hud setText:@"Error Saving"];
    [hud setState:kProgressHUDStateError];
    [hud dismissAfterDelay:0.8f animated:YES];
}


@end
