//
//  HNSession.m
//  Orangey
//
//  Created by Grant Paul on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNSession.h"
#import "HNKit.h"

static HNSession *current = nil;

@implementation HNSession
@synthesize user, token, loaded;

+ (id)currentSession {
    return current;
}

+ (void)setCurrentSession:(HNSession *)session {
    [current autorelease];
    current = [session retain];
}

- (id)initWithUsername:(HNUser *)username token:(NSString *)token_ {
    if ((self = [super init])) {
        HNUser *user_ = [[HNUser alloc] initWithIdentifier:username];
        
        [self setUser:[user_ autorelease]];
        [self setToken:token_];
        [self setLoaded:YES];
    }
    
    return self;
}

@end
