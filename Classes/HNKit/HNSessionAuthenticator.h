//
//  HNSessionAuthenticator.h
//  newsyc
//
//  Created by Grant Paul on 3/21/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"
#import "HNSession.h"

@protocol HNSessionAuthenticatorDelegate;

@interface HNSessionAuthenticator : NSObject {
    NSURLConnection *connection;
    
    __weak id<HNSessionAuthenticatorDelegate> delegate;
    NSString *username;
    NSString *password;
}

@property (nonatomic, assign) id<HNSessionAuthenticatorDelegate> delegate;

- (id)initWithUsername:(NSString *)username password:(NSString *)password;
- (void)beginAuthenticationRequest;

@end

@protocol HNSessionAuthenticatorDelegate <NSObject>

// Success: we got a token.
- (void)sessionAuthenticator:(HNSessionAuthenticator *)authenticator didRecieveToken:(HNSessionToken)token;
// Failure: username or password invalid or network error.
- (void)sessionAuthenticatorDidRecieveFailure:(HNSessionAuthenticator *)authenticator;

@end
