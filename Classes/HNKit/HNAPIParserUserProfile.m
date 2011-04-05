//
//  HNAPIParserUserProfile.m
//  newsyc
//
//  Created by Grant Paul on 3/12/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNAPIParserUserProfile.h"

@implementation HNAPIParserUserProfile

- (id)parseString:(NSString *)string options:(NSDictionary *)options {
    NSScanner *scanner = [NSScanner scannerWithString:string];
    NSString *key = nil, *value = nil;
    
    NSString *start = @"<tr><td valign=top>";
    NSString *mid = @":</td><td>";
    NSString *end = @"</td></tr>";
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    while ([scanner isAtEnd] == NO) {
        [scanner scanUpToString:start intoString:NULL];
        [scanner scanUpToString:mid intoString:&key];
        [scanner scanUpToString:end intoString:&value];
        if ([key hasPrefix:start]) key = [key substringFromIndex:[start length]];
        if ([value hasPrefix:mid]) value = [value substringFromIndex:[mid length]];
        
        if ([key isEqual:@"about"]) {
            [result setObject:value forKey:@"about"];
        } else if ([key isEqual:@"karma"]) {
            [result setObject:value forKey:@"karma"];
        } else if ([key isEqual:@"avg"]) {
            [result setObject:value forKey:@"average"];
        } else if ([key isEqual:@"created"]) {
            [result setObject:value forKey:@"created"];
        }
    }
    
    return result;
}

@end
