//
//  InstapaperAuthenticator.h
//  newsyc
//
//  Created by Grant Paul on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InstapaperAPI.h"

@protocol InstapaperAuthenticatorDelegate;
@interface InstapaperAuthenticator : NSObject {
    NSString *username;
    NSString *password;
    id<InstapaperAuthenticatorDelegate> delegate;
}

@property (nonatomic, assign) id<InstapaperAuthenticatorDelegate> delegate;

- (id)initWithUsername:(NSString *)username_ password:(NSString *)password_;
- (void)beginAuthentication;

@end

@protocol InstapaperAuthenticatorDelegate <NSObject>
@optional

- (void)instapaperAuthenticatorDidSucceed:(InstapaperAuthenticator *)auth;
- (void)instapaperAuthenticator:(InstapaperAuthenticator *)auth didFailWithError:(NSError *)error;

@end