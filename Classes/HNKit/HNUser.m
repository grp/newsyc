//
//  HNUser.m
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "NSURL+Parameters.h"

#import "HNKit.h"
#import "HNUser.h"

@implementation HNUser
@synthesize karma, average, created, about;

+ (id)identifierForURL:(NSURL *)url_ {
    if (![self isValidURL:url_]) return NO;
    
    NSDictionary *parameters = [url_ parameterDictionary];
    return [parameters objectForKey:@"id"];
}

+ (NSString *)pathForURLWithIdentifier:(id)identifier_ infoDictionary:(NSDictionary *)info {
    return @"user";
}

+ (NSDictionary *)parametersForURLWithIdentifier:(id)identifier_ infoDictionary:(NSDictionary *)info {
    if (identifier_ != nil) return [NSDictionary dictionaryWithObject:identifier_ forKey:@"id"];
    else return [NSDictionary dictionary];
}

+ (id)userWithIdentifier:(id)identifier_ {
    return [self objectWithIdentifier:identifier_];
}

- (void)finishLoadingWithResponse:(NSDictionary *)response error:(NSError *)error {
    if (error == nil) {
        [self setAbout:[response objectForKey:@"about"]];
        [self setKarma:[[response objectForKey:@"karma"] intValue]];
        [self setAverage:[[response objectForKey:@"average"] floatValue]];
        [self setCreated:[[response objectForKey:@"created"] stringByRemovingSuffix:@" ago"]];
    }
}

@end
