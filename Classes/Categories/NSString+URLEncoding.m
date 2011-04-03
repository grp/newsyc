//
//  NSString+URLEncoding.m
//  Orangey
//
//  Created by Grant Paul on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+URLEncoding.h"

@implementation NSString (URLEncoding)

- (NSString *)stringByURLEncodingString {
    CFStringRef encoded = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) self, NULL, (CFStringRef) @"!*'\"();:@&=+$,/?%#[]% ", kCFStringEncodingUTF8);
    return [(NSString *) encoded autorelease];
}

@end
