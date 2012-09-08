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

- (void)loadContentsDictionary:(NSDictionary *)contents {
    [self setAbout:[contents objectForKey:@"about"]];
    [self setKarma:[[contents objectForKey:@"karma"] intValue]];
    [self setAverage:[[contents objectForKey:@"average"] floatValue]];
    // FIXME: make this a date
    [self setCreated:[[contents objectForKey:@"created"] stringByRemovingSuffix:@" ago"]];

    [super loadContentsDictionary:contents];
}

- (NSDictionary *)contentsDictionary {
    NSMutableDictionary *dictionary = [[[super contentsDictionary] mutableCopy] autorelease];

    if (about != nil) [dictionary setObject:about forKey:@"about"];
    [dictionary setObject:[NSNumber numberWithInt:karma] forKey:@"karma"];
    [dictionary setObject:[NSNumber numberWithFloat:average] forKey:@"average"];
    if (created != nil) [dictionary setObject:created forKey:@"created"];

    return dictionary;
}

@end
