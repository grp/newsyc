//
//  HNAPIRequestParser.h
//  newsyc
//
//  Created by Grant Paul on 3/12/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"

@interface HNAPIRequestParser : NSObject {
    HNPageType type;
}

- (id)initWithType:(HNPageType)type_;

- (NSDictionary *)parseUserProfileWithString:(NSString *)string;
- (NSDictionary *)parseCommentTreeWithString:(NSString *)string;
- (NSDictionary *)parseSubmissionsWithString:(NSString *)string;

@end
