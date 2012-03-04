//
//  HNAPIRequestParser.h
//  newsyc
//
//  Created by Grant Paul on 3/12/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"

@interface HNAPIRequestParser : NSObject {
}

- (NSDictionary *)parseWithString:(NSString *)string;

@end
