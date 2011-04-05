//
//  NSString+RemoveSuffix.m
//  newsyc
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "NSString+RemoveSuffix.h"

@implementation NSString (RemoveSuffix)

- (NSString *)stringByRemovingSuffix:(NSString *)s {
    if([self hasSuffix:s])
        self = [self substringToIndex:[self length] - [s length]];
    return self;
}

@end
