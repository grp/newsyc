//
//  NSDictionary+Parameters.m
//  newsyc
//
//  Created by Grant Paul on 3/13/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "NSDictionary+Parameters.h"
#import <HNKit/NSString+URLEncoding.h>

@implementation NSDictionary (Parameters)

- (NSString *)queryString {
    NSMutableArray *parameters = [NSMutableArray array];
    for (NSString *key in [self allKeys]) {
        NSString *escapedk = [key stringByURLEncodingString];
        NSString *v = [self[key] isKindOfClass:[NSString class]] ? self[key] : [self[key] stringValue];
        NSString *escapedv = [v stringByURLEncodingString];
        [parameters addObject:[NSString stringWithFormat:@"%@=%@", escapedk, escapedv]];
    }
    
    NSString *query = [parameters count] > 0 ? @"?" : @"";
    query = [query stringByAppendingString:[parameters componentsJoinedByString:@"&"]];
    return query;
}

@end
