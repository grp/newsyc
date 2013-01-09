//
//  HNSession.h
//  newsyc
//
//  Created by Grant Paul on 3/13/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"
#import "HNSessionAuthenticator.h"

@class HNUser, HNEntry, HNSubmission, HNObjectCache;
@interface HNSession : NSObject <HNSessionAuthenticatorDelegate> {
    BOOL loaded;
    HNSessionToken token;
    HNUser *user;
    NSString *password;
    HNSessionAuthenticator *authenticator;
    HNObjectCache *cache;
    
    NSDictionary *pool;
}

@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) HNUser *user;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign, getter=isLoaded) BOOL loaded;
@property (nonatomic, retain, readonly) NSString *identifier;
@property (nonatomic, retain, readonly) HNObjectCache *cache;

- (id)initWithUsername:(NSString *)username password:(NSString *)password token:(HNSessionToken)token;
- (id)initWithSessionDictionary:(NSDictionary *)sessionDictionary;

- (NSDictionary *)sessionDictionary;

- (void)performSubmission:(HNSubmission *)submission;
- (void)reloadToken;

- (void)addCookiesToRequest:(NSMutableURLRequest *)request;

@end
