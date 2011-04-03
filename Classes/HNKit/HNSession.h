//
//  HNSession.h
//  Orangey
//
//  Created by Grant Paul on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNKit.h"

typedef NSString *HNSessionToken;

@class HNUser, HNEntry;
@interface HNSession : NSObject {
    BOOL loaded;
    HNSessionToken token;
    HNUser *user;
}

@property (nonatomic, retain) HNUser *user;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign, getter=isLoaded) BOOL loaded;

+ (HNSession *)currentSession;
+ (void)setCurrentSession:(HNSession *)session;

- (id)initWithUsername:(NSString *)username token:(HNSessionToken)token;

- (void)flagEntry:(HNEntry *)entry target:(id)target action:(SEL)action;
- (void)voteEntry:(HNEntry *)entry inDirection:(HNVoteDirection)direction target:(id)target action:(SEL)action;
- (void)replyToEntry:(HNEntry *)entry withBody:(NSString *)body target:(id)target action:(SEL)action;
- (void)submitEntryWithTitle:(NSString *)title body:(NSString *)body URL:(NSURL *)url target:(id)target action:(SEL)action;

@end
