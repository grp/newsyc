//
//  HNSession.m
//  Orangey
//
//  Created by Grant Paul on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNKit.h"
#import "HNSession.h"
#import "HNAPISubmission.h"
#import "HNSubmission.h"

static HNSession *current = nil;

@implementation HNSession
@synthesize user, token, loaded;

+ (HNSession *)currentSession {
    return current;
}

+ (void)setCurrentSession:(HNSession *)session {
    [current autorelease];
    current = [session retain];
    
    if (session != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:[session token] forKey:@"HNKit:SessionToken"];
        [[NSUserDefaults standardUserDefaults] setObject:[[session user] identifier] forKey:@"HNKit:SessionName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"HNKit:SessionToken"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"HNKit:SessionName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)initialize {
    // XXX: is it safe to use NSUserDefaults here?
    HNSessionToken token = (HNSessionToken) [[NSUserDefaults standardUserDefaults] objectForKey:@"HNKit:SessionToken"];
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"HNKit:SessionName"];
    
    if (name != nil && token != nil) {
        HNSession *session = [[HNSession alloc] initWithUsername:name token:token];
        [self setCurrentSession:[session autorelease]];
    }
}

- (id)initWithUsername:(NSString *)username token:(NSString *)token_ {
    if ((self = [super init])) {
        HNUser *user_ = [[HNUser alloc] initWithIdentifier:username];
        
        [self setUser:[user_ autorelease]];
        [self setToken:token_];
        [self setLoaded:YES];
    }
    
    return self;
}

- (void)_performSubmission:(HNSubmission *)submission target:(id)target action:(SEL)action {
    HNAPISubmission *api = [[HNAPISubmission alloc] initWithTarget:target action:action];
    [api performSubmission:submission withToken:[self token]];
}

- (void)flagEntry:(HNEntry *)entry target:(id)target action:(SEL)action {
    HNSubmission *submission = [[HNSubmission alloc] initWithSubmissionType:kHNSubmissionTypeFlag];
    [submission setTarget:entry];
    [self _performSubmission:submission target:target action:action];
}

- (void)voteEntry:(HNEntry *)entry inDirection:(HNVoteDirection)direction target:(id)target action:(SEL)action {
    HNSubmission *submission = [[HNSubmission alloc] initWithSubmissionType:kHNSubmissionTypeVote];
    [submission setDirection:direction];
    [submission setTarget:entry];
    [self _performSubmission:submission target:target action:action];
}

- (void)replyToEntry:(HNEntry *)entry withBody:(NSString *)body target:(id)target action:(SEL)action {
    HNSubmission *submission = [[HNSubmission alloc] initWithSubmissionType:kHNSubmissionTypeReply];
    [submission setBody:body];
    [submission setTarget:entry];
    [self _performSubmission:submission target:target action:action];
}

- (void)submitEntryWithTitle:(NSString *)title body:(NSString *)body URL:(NSURL *)url target:(id)target action:(SEL)action {
    HNSubmission *submission = [[HNSubmission alloc] initWithSubmissionType:kHNSubmissionTypeSubmission];
    [submission setBody:body];
    [submission setTitle:title];
    [submission setDestination:url];
    [self _performSubmission:submission target:target action:action];
}

@end
