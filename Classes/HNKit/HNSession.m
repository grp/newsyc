//
//  HNSession.m
//  newsyc
//
//  Created by Grant Paul on 3/13/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"
#import "HNSession.h"
#import "HNObjectCache.h"
#import "HNAPISubmission.h"
#import "HNSubmission.h"
#import "HNAnonymousSession.h"

@implementation HNSession
@synthesize user, token, loaded, password, cache;

- (id)initWithUsername:(NSString *)username password:(NSString *)password_ token:(NSString *)token_ {
    if ((self = [super init])) {
        cache = [[HNObjectCache alloc] initWithSession:self];

        if (username != nil) {
            HNUser *user_ = [HNUser session:self userWithIdentifier:username];
            [self setUser:user_];
        }
        
        [self setToken:token_];
        [self setPassword:password_];

        [self setLoaded:YES];

        [cache createPersistentCache];
    }

    return self;
}

- (id)initWithSessionDictionary:(NSDictionary *)sessionDictionary {
    HNSessionToken token_ = (HNSessionToken) [sessionDictionary objectForKey:@"HNKit:HNSession:Token"];
    NSString *password_ = [sessionDictionary objectForKey:@"HNKit:HNSession:Password"];
    NSString *name_ = [sessionDictionary objectForKey:@"HNKit:HNSession:Identifier"];

    return [self initWithUsername:name_ password:password_ token:token_];
}

- (NSDictionary *)sessionDictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:
        token, @"HNKit:HNSession:Token",
        password, @"HNKit:HNSession:Password",
        [self identifier], @"HNKit:HNSession:Identifier",
    nil];
}

- (NSString *)identifier {
    return [[self user] identifier];
}

- (void)dealloc {
    [cache release];

    [super dealloc];
}

- (void)sessionAuthenticatorDidRecieveFailure:(HNSessionAuthenticator *)authenticator_ {
    [authenticator autorelease];
    authenticator = nil;
}

- (void)sessionAuthenticator:(HNSessionAuthenticator *)authenticator_ didRecieveToken:(HNSessionToken)token_ {
    [authenticator autorelease];
    authenticator = nil;
    
    [self setToken:token_];
}

- (void)reloadToken {
    // XXX: maybe this should return an error code
    if (authenticator != nil) return;
    
    authenticator = [[HNSessionAuthenticator alloc] initWithUsername:[user identifier] password:password];
    [authenticator setDelegate:self];
    [authenticator beginAuthenticationRequest];
}

- (void)performSubmission:(HNSubmission *)submission {
    HNAPISubmission *api = [[HNAPISubmission alloc] initWithSession:self submission:submission];
    [api performSubmission];
    [api autorelease];
}

- (void)addCookiesToRequest:(NSMutableURLRequest *)request {
    if (token == nil) return;
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                kHNWebsiteHost, NSHTTPCookieDomain,
                                @"/", NSHTTPCookiePath,
                                @"user", NSHTTPCookieName,
                                (NSString *) token, NSHTTPCookieValue,
                                nil];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[NSArray arrayWithObject:cookie]];
    [request setAllHTTPHeaderFields:headers];
}

@end
