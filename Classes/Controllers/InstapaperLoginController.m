//
//  InstapaperLoginController.m
//  newsyc
//
//  Created by Alex Galonsky on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InstapaperLoginController.h"
#import "InstapaperSession.h"

@implementation InstapaperLoginController
@synthesize pendingURL;

- (void)dealloc {
    [super dealloc];
}

- (BOOL)requiresPassword {
    return NO;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [topLabel setText:@"Instapaper"];
    [topLabel setTextColor:[UIColor blackColor]];
    [topLabel setShadowColor:[UIColor clearColor]];
    [topLabel setFont:[UIFont fontWithName:@"Georgia" size:36.0f]];
    [bottomLabel setText:@"Enter your password if you have one."];
    [bottomLabel setTextColor:[UIColor blackColor]];
}

- (NSArray *)gradientColors {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:(id) [[UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.0f] CGColor]];
    [array addObject:(id) [[UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f] CGColor]];
    return array;
}

- (void)instapaperAuthenticator:(InstapaperAuthenticator *)auth didFailWithError:(NSError *)error {
    [bottomLabel setText:[NSString stringWithFormat:@"Error: %@", [error localizedDescription]]];
    [auth release];
    
    [self finish];
    [self fail];
}

- (void)instapaperAuthenticatorDidSucceed:(InstapaperAuthenticator *)auth {
    InstapaperSession *session = [[InstapaperSession alloc] init];
    [session setUsername:[usernameField text]];
    [session setPassword:[passwordField text]];
    [InstapaperSession setCurrentSession:session];
    [auth release];
    [session release];
    
    [self finish];
    [self succeed];
}

- (void)authenticate {
	[super authenticate];
    InstapaperAuthenticator *auth = [[InstapaperAuthenticator alloc] initWithUsername:[usernameField text] password:[passwordField text]];
    [auth setDelegate:self];
    [auth beginAuthentication];
}

@end
