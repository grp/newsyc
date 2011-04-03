//
//  HNObject.m
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSURL+Parameters.h"
#import "NSDictionary+Parameters.h"

#import "HNKit.h"
#import "HNObject.h"

@implementation HNObject
@synthesize identifier, loadingState, URL=url, type, delegate;

+ (id)_parseParametersWithType:(HNPageType)type_ parameters:(NSDictionary *)parameters {
    return nil;
}

+ (id)parseURL:(NSURL *)url_ {
    if (![[url_ scheme] isEqualToString:@"http"] && ![[url_ scheme] isEqualToString:@"https"]) return nil;
    if (![[url_ host] isEqualToString:kHNWebsiteHost]) return nil;
    
    NSString *type_ = [url_ path];
    if ([[type_ substringToIndex:1] isEqual:@"/"]) type_ = [type_ substringFromIndex:1];
    id identifier_ = [self _parseParametersWithType:type_ parameters:[url_ parameterDictionary]];
    return [NSDictionary dictionaryWithObjectsAndKeys:type_, @"type", identifier_, @"identifier", nil];
}

+ (NSDictionary *)_generateParametersWithType:(HNPageType)type_ identifier:(id)identifier_ {
    return [NSDictionary dictionary];
}

+ (NSURL *)generateURLWithType:(HNPageType)type_ identifier:(id)identifier_ {
    NSDictionary *parameters = [self _generateParametersWithType:type_ identifier:identifier_];
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [kHNWebsiteURL absoluteString], type_, [parameters queryString]]];
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
    if ([self isLoaded]) other = [self _additionalDescription];
    else other = @"[not loaded]";
    
    NSString *identifier_ = [NSString stringWithFormat:@" identifier=%@", identifier];
    if (identifier == nil) identifier_ = @"";
    
    return [NSString stringWithFormat:@"<%@:%p type=%@%@ %@>", [self class], self, type, identifier_, other];
}

#pragma mark -
#pragma mark Loading

- (void)clearLoadingState:(HNObjectLoadingState)state_ {
    loadingState &= ~state_;
    
    if ([delegate respondsToSelector:@selector(objectChangedLoadingState:)]) [delegate objectChangedLoadingState:self];
}

- (void)addLoadingState:(HNObjectLoadingState)state_ {
    loadingState |= state_;
    
    if ((state_ & kHNObjectLoadingStateLoaded) > 0) {
        if ([delegate respondsToSelector:@selector(objectFinishedLoading:)]) [delegate objectFinishedLoading:self];
    }
    
    if ([delegate respondsToSelector:@selector(objectChangedLoadingState:)]) [delegate objectChangedLoadingState:self];
}

- (BOOL)isLoaded {
    return ([self loadingState] & kHNObjectLoadingStateLoaded) > 0;
}

- (BOOL)isLoading {
    return ([self loadingState] & kHNObjectLoadingStateLoadingAny) > 0;
}
            
- (void)finishLoadingWithResponse:(NSDictionary *)response error:(NSError *)error {
    // NOTE: overridden in subclasses
}

- (void)_clearRequest {
    if ([apiRequest isLoading]) [apiRequest cancelRequest];
    [apiRequest release];
    apiRequest = nil;
    
    [self clearLoadingState:kHNObjectLoadingStateLoadingAny];
}

- (void)request:(HNAPIRequest *)request completedWithResponse:(NSDictionary *)response error:(NSError *)error {
    [self finishLoadingWithResponse:response error:error];
    
    // XXX: this MUST MUST MUST be above the code below
    // move it below at penalty of death
    [self _clearRequest];
    
    if (error == nil) {
        [self addLoadingState:kHNObjectLoadingStateLoaded];
    } else {
        if ([delegate respondsToSelector:@selector(object:failedToLoadWithError:)]) [delegate object:self failedToLoadWithError:error];
    }
}

- (void)_beginLoadingWithState:(HNObjectLoadingState)state_ {
    // Loading multiple times at once just makes no sense.
    if ([self isLoading]) return;
    
    [self addLoadingState:state_];
    apiRequest = [[HNAPIRequest alloc] initWithTarget:self action:@selector(request:completedWithResponse:error:)];
    [apiRequest performRequestOfType:type withParameters:[[self class] _generateParametersWithType:type identifier:identifier]];
}

- (void)cancelLoading {
    [self _clearRequest];
}

- (void)beginLoading {
    // If we've already loaded, an initial makes no sense.
    if ([self isLoaded]) return;
    [self _beginLoadingWithState:kHNObjectLoadingStateLoadingInitial];
}

- (void)beginReloading {
    [self _beginLoadingWithState:kHNObjectLoadingStateLoadingReload];
}

@end
