//
//  HNSession.h
//  Orangey
//
//  Created by Grant Paul on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class HNUser;
@interface HNSession : NSObject {
    NSString *token;
    HNUser *user;
}

@property (nonatomic, retain) HNUser *user;
@property (nonatomic, copy) NSString *token;

- (id)initWithUser:(HNUser *)user token:(NSString *)token;
- (id)initWithUser:(HNUser *)user password:(NSString *)password;

@end
