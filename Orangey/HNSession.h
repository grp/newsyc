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
    HNSessionToken token;
    HNUser *user;
}

@property (nonatomic, retain) HNUser *user;
@property (nonatomic, copy) NSString *token;

- (id)initWithUser:(HNUser *)user token:(HNSessionToken)token;
- (id)initWithUser:(HNUser *)user password:(NSString *)password;

@end
