//
//  HNSession.h
//  newsyc
//
//  Created by Grant Paul on 3/13/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#include "HNSessionAuthenticator.h"

@class HNUser, HNEntry;
@interface HNSession : NSObject <HNSessionAuthenticatorDelegate> {
    BOOL loaded;
    HNSessionToken token;
    HNUser *user;
    NSString *password;
    HNSessionAuthenticator *authenticator;
    
    NSDictionary *pool;
}

@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) HNUser *user;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign, getter=isLoaded) BOOL loaded;
@property (nonatomic, readonly) BOOL isAnonymous;

+ (HNSession *)currentSession;
+ (void)setCurrentSession:(HNSession *)session;

- (id)initWithUsername:(NSString *)username password:(NSString *)password token:(HNSessionToken)token;

- (void)flagEntry:(HNEntry *)entry target:(id)target action:(SEL)action;
- (void)voteEntry:(HNEntry *)entry inDirection:(HNVoteDirection)direction target:(id)target action:(SEL)action;
- (void)replyToEntry:(HNEntry *)entry withBody:(NSString *)body target:(id)target action:(SEL)action;
- (void)submitEntryWithTitle:(NSString *)title body:(NSString *)body URL:(NSURL *)url target:(id)target action:(SEL)action;

- (void)reloadToken;

@end
