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

- (id)initWithUser:(HNUser *)user_ token:(NSString *)token_ {
    if ((self = [super init])) {
        [self setUser:user_];
        [self setToken:token_];
        [self setLoaded:YES];
    }
    
    return self;
}

@end
