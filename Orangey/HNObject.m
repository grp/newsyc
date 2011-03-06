//
//  HNObject.m
//  Orangey
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSURL+Parameters.h"

#import "HNKit.h"
#import "HNObject.h"

@implementation HNObject
@synthesize identifier, loaded, URL=url;

+ (id)_parseParameters:(NSDictionary *)parameters {
    return nil;
}

+ (id)_parseURL:(NSURL *)url_ {
    NSDictionary *parameters = [url_ parameterDictionary];
    return [self _parseParameters:parameters];
}

+ (id)parseURL:(NSURL *)url_ {
    if (![[url_ scheme] isEqualToString:@"http"] && ![[url_ scheme] isEqualToString:@"https"]) return nil;
    if (![[url_ host] isEqualToString:kHNWebsiteHost]) return nil;
    return [self _parseURL:url_];
}

+ (NSURL *)generateURL:(id)identifier_ {
    return nil;
}

- (HNObject *)initWithIdentifier:(id)identifier_ URL:(NSURL *)url_ {
    if (identifier_ != nil && url_ != nil && (self = [super init])) {
        [self setURL:url_];
        [self setIdentifier:identifier_];
    }
    
    return self;
}

- (HNObject *)initWithIdentifier:(id)identifier_ {
    return [self initWithIdentifier:identifier_ URL:[[self class] generateURL:identifier_]];
}

- (HNObject *)initWithURL:(NSURL *)url_ {
    return [self initWithIdentifier:[[self class] parseURL:url_] URL:url_];
}

- (void)didFinishLoadingWithError:(NSError *)error {    
    if (error == nil) {
        [self setLoaded:YES];
        
        [target performSelector:action withObject:self];
        target = nil;
        action = NULL;
    }
}

- (void)didFinishLoading {
    [self didFinishLoadingWithError:nil];
}

- (void)cancelLoading {
    [apiRequest cancelRequest];
    [apiRequest release];
    apiRequest = nil;
}

- (void)_load {
    // Overriden in subclasses.
}

- (void)beginLoadingWithTarget:(id)target_ action:(SEL)action_ {
    target = target_;
    action = action_;
    
    [self _load];
}

- (void)beginLoading {
    return [self beginLoadingWithTarget:nil action:NULL];
}

@end
