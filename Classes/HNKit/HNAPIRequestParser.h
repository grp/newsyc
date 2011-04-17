//
//  HNAPIRequestParser.h
//  newsyc
//
//  Created by Grant Paul on 3/12/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

@interface HNAPIRequestParser : NSObject {
    
}

- (NSDictionary *)parseUserProfileWithString:(NSString *)string;

- (NSDictionary *)parseCommentTreeWithString:(NSString *)string;
- (NSDictionary *)parseSubmissionsWithString:(NSString *)string;

@end
