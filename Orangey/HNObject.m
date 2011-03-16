//
//  HNObject.m
//  Orangey
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSURL+Parameters.h"
#import "NSDictionary+Parameters.h"

#import "HNKit.h"
#import "HNObject.h"

@implementation HNObject
@synthesize identifier, loaded, URL=url, type;

+ (id)_parseParametersWithType:(HNPageType)type_ parameters:(NSDictionary *)parameters {
    return nil;
}

+ (id)parseURL:(NSURL *)url_ {
    if (![[url_ scheme] isEqualToString:@"http"] && ![[url_ scheme] isEqualToString:@"https"]) return nil;
    if (![[url_ host] isEqualToString:kHNWebsiteHost]) return nil;
    
    NSString *type_ = [url_ path];
    id identifier_ = [self _parseParametersWithType:type_ parameters:[url_ parameterDictionary]];
    return [NSDictionary dictionaryWithObjectsAndKeys:type_, @"type", identifier_, @"identifier", nil];
}

+ (NSDictionary *)_generateParametersWithType:(HNPageType)type_ identifier:(id)identifier_ {
    return [NSDictionary dictionary];
}

+ (NSURL *)generateURLWithType:(HNPageType)type_ identifier:(id)identifier_ {
    NSDictionary *parameters = [self _generateParametersWithType:type_ identifier:identifier_];
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@%@", kHNWebsiteHost, type_, [parameters queryString]]];
}
            
+ (NSURL *)generateURLWithType:(HNPageType)type_ {
    return [self generateURLWithType:type_ identifier:nil];
}

- (id)initWithType:(HNPageType)type_ identifier:(id)identifier_ URL:(NSURL *)url_ {
    if (type_ != nil && url_ != nil && (self = [super init])) {
        [self setURL:url_];
        [self setType:type_];
        [self setIdentifier:identifier_];
    }
    
    return self;
}

- (id)initWithType:(HNPageType)type_ identifier:(id)identifier_ {
    return [self initWithType:type_ identifier:identifier_ URL:[[self class] generateURLWithType:type_ identifier:identifier_]];
}
            
- (id)initWithType:(HNPageType)type_ {
    return [self initWithType:type_ identifier:nil];
}

- (id)initWithURL:(NSURL *)url_ {
    NSDictionary *parsed = [[self class] parseURL:url_];
    return [self initWithType:[parsed objectForKey:@"type"] identifier:[parsed objectForKey:@"identifier"] URL:url_];
}
            
- (NSString *)_additionalDescription {
    return @"";
}
            
- (NSString *)description {
    NSString *other = nil;
    if (loaded) other = [self _additionalDescription];
    else other = @"[not loaded]";
    
    NSString *identifier_ = [NSString stringWithFormat:@" identifier=%@", identifier];
    if (identifier == nil) identifier_ = @"";
    
    return [NSString stringWithFormat:@"<%@:%p type=%@%@ %@>", [self class], self, type, identifier_, other];
}

- (void)didFinishLoadingWithError:(NSError *)error {    
    if (error == nil) [self setLoaded:YES];
        
    [target performSelector:action withObject:self withObject:error];
    target = nil;
    action = NULL;
}
            
- (void)finishLoadingWithResponse:(NSDictionary *)response {
    // overridden in subclasses
}

- (void)request:(HNAPIRequest *)request completedWithResponse:(NSDictionary *)response error:(NSError *)error {
    if (error == nil) [self finishLoadingWithResponse:response];
    
    [apiRequest autorelease];
    apiRequest = nil;
    [self didFinishLoadingWithError:error];
}

- (void)cancelLoading {
    [apiRequest cancelRequest];
    [apiRequest release];
    apiRequest = nil;
}

- (void)beginLoadingWithTarget:(id)target_ action:(SEL)action_ {
    target = target_;
    action = action_;
    
    apiRequest = [[HNAPIRequest alloc] initWithTarget:self action:@selector(request:completedWithResponse:error:)];
    [apiRequest performRequestOfType:type withParameters:[[self class] _generateParametersWithType:type identifier:identifier]];
}

- (void)beginLoading {
    return [self beginLoadingWithTarget:nil action:NULL];
}

@end
