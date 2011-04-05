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

- (id)initWithIdentifier:(id)identifier_ {
    return [self initWithType:kHNPageTypeUserProfile identifier:identifier_];
}

+ (id)_parseParametersWithType:(HNPageType)type_ parameters:(NSDictionary *)parameters {
    return [parameters objectForKey:@"id"];
}

+ (NSDictionary *)_generateParametersWithType:(HNPageType)type_ identifier:(id)identifier_ {
    if (identifier_ != nil) return [NSDictionary dictionaryWithObject:identifier_ forKey:@"id"];
    else return [NSDictionary dictionary];
}

- (NSString *)_additionalDescription {
    return [NSString stringWithFormat:@"karma=%d average=%f created=%@ about=%@", karma, average, created, about];
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
