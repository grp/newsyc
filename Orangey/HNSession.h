//
//  HNSession.h
//  Orangey
//
//  Created by Grant Paul on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

typedef enum {
    kHNVoteDirectionDown,
    kHNVoteDirectionUp
} HNVoteDirection;

typedef NSString *HNSessionToken;

@class HNUser;
@interface HNSession : NSObject {
    BOOL loaded;
    HNSessionToken token;
    HNUser *user;
}

@property (nonatomic, retain) HNUser *user;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign, getter=isLoaded) BOOL loaded;

+ (id)currentSession;
+ (void)setCurrentSession:(HNSession *)session;

- (id)initWithUsername:(NSString *)username token:(HNSessionToken)token;

@end
