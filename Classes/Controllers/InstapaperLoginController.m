//
//  InstapaperLoginController.m
//  newsyc
//
//  Created by Grant Paul on 4/6/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "InstapaperLoginController.h"
#import "InstapaperSession.h"

@implementation InstapaperLoginController
@synthesize pendingURL;


- (BOOL)requiresPassword {
    return NO;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [topLabel setText:@"Instapaper"];
    [bottomLabel setText:@"Enter your password if you have one."];


    [[usernameCell textLabel] setText:@"Email"];

    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        [topLabel setTextColor:[UIColor blackColor]];
        [bottomLabel setTextColor:[UIColor darkGrayColor]];
    } else {
        [topLabel setTextColor:[UIColor blackColor]];
        [bottomLabel setTextColor:[UIColor blackColor]];
    }

    [topLabel setFont:[UIFont fontWithName:@"HoeflerText-Regular" size:34.0f]];
    [bottomLabel setFont:[UIFont systemFontOfSize:14.0f]];
}

- (NSArray *)gradientColors {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:(id) [[UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.0f] CGColor]];
    [array addObject:(id) [[UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f] CGColor]];
    return array;
}

- (void)instapaperAuthenticator:(InstapaperAuthenticator *)auth didFailWithError:(NSError *)error {
    [bottomLabel setText:[NSString stringWithFormat:@"Error: %@", [error localizedDescription]]];
    
    [self finish];
    [self fail];
}

- (void)instapaperAuthenticatorDidSucceed:(InstapaperAuthenticator *)auth {
    InstapaperSession *session = [[InstapaperSession alloc] init];
    [session setUsername:[usernameField text]];
    [session setPassword:[passwordField text]];
    [InstapaperSession setCurrentSession:session];
    
    [self finish];
    [self succeed];
}

- (void)authenticate {
	[super authenticate];
    InstapaperAuthenticator *auth = [[InstapaperAuthenticator alloc] initWithUsername:[usernameField text] password:[passwordField text]];
    [auth setDelegate:self];
    [auth beginAuthentication];
}

AUTOROTATION_FOR_PAD_ONLY

@end
