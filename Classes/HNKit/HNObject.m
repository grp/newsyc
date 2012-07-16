//
//  HNObject.m
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "NSURL+Parameters.h"
#import "NSDictionary+Parameters.h"

#import "HNKit.h"
#import "HNObject.h"
#import "HNObjectCache.h"

@implementation HNObject
@synthesize identifier, URL=url;
@synthesize loadingState;

+ (BOOL)isValidURL:(NSURL *)url_ {
    if (url_ == nil) return NO;
    if (![[url_ scheme] isEqualToString:@"http"] && ![[url_ scheme] isEqualToString:@"https"]) return NO;
    if (![[url_ host] isEqualToString:kHNWebsiteHost]) return NO;
    
    return YES;
}

+ (NSDictionary *)infoDictionaryForURL:(NSURL *)url_ {
    return nil;
}

+ (id)identifierForURL:(NSURL *)url_ {
    return nil;
}

+ (NSString *)pathForURLWithIdentifier:(id)identifier_ infoDictionary:(NSDictionary *)info {
    return nil;
}

+ (NSDictionary *)parametersForURLWithIdentifier:(id)identifier_ infoDictionary:(NSDictionary *)info {
    return nil;
}

+ (NSURL *)generateURLWithIdentifier:(id)identifier_ infoDictionary:(NSDictionary *)info {
    NSDictionary *parameters = [self parametersForURLWithIdentifier:identifier_ infoDictionary:info];
    NSString *path = [self pathForURLWithIdentifier:identifier_ infoDictionary:info];
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [kHNWebsiteURL absoluteString], path, [parameters queryString]]];
}

+ (id)objectWithIdentifier:(id)identifier_ infoDictionary:(NSDictionary *)info URL:(NSURL *)url_ {
    HNObject *object = [HNObjectCache objectFromCacheWithClass:self identifier:identifier_ infoDictionary:info];
    
    if (object == nil) {
        object = [[[self alloc] init] autorelease];
    }
    
    if (url_ != nil) {
        [object setURL:url_];
        [object setIdentifier:identifier_];
        
        [object loadInfoDictionary:info];
        
        [HNObjectCache addObjectToCache:object];
    }
    
    return object;
}

+ (id)objectWithIdentifier:(id)identifier_ infoDictionary:(NSDictionary *)info {
    return [self objectWithIdentifier:identifier_ infoDictionary:info URL:[[self class] generateURLWithIdentifier:identifier_ infoDictionary:info]];
}

+ (id)objectWithIdentifier:(id)identifier_ {
    return [self objectWithIdentifier:identifier_ infoDictionary:nil];
}

+ (id)objectWithURL:(NSURL *)url_ {
    id identifier_ = [self identifierForURL:url_];
    NSDictionary *info = [self infoDictionaryForURL:url_];
    return [self objectWithIdentifier:identifier_ infoDictionary:info URL:url_];
}

+ (NSString *)pathWithIdentifier:(id)identifier {
    return nil;
}

- (NSDictionary *)infoDictionary {
    return nil;
}

- (void)loadInfoDictionary:(NSDictionary *)info {
    return;
}

- (NSString *)description {
    NSString *other = nil;
    
    if (![self isLoaded]) {
        other = @"[not loaded]";
    }
    
    NSString *identifier_ = [NSString stringWithFormat:@" identifier=%@", identifier];
    if (identifier == nil) identifier_ = @"";
    
    return [NSString stringWithFormat:@"<%@:%p %@ %@>", [self class], self, identifier_, other];
}

#pragma mark - Loading

- (void)clearLoadingState:(HNObjectLoadingState)state_ {
    loadingState &= ~state_;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHNObjectLoadingStateChangedNotification object:self];
}

- (void)addLoadingState:(HNObjectLoadingState)state_ {
    loadingState |= state_;
    
    if ((state_ & kHNObjectLoadingStateLoaded) > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHNObjectFinishedLoadingNotification object:self];
    } else if ((state_ & kHNObjectLoadingStateLoadingAny) > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHNObjectStartedLoadingNotification object:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHNObjectLoadingStateChangedNotification object:self];
}

- (BOOL)hasLoadingState:(HNObjectLoadingState)state_ {
    return ([self loadingState] & state_) > 0;
}

- (BOOL)isLoaded {
    return [self hasLoadingState:kHNObjectLoadingStateLoaded];
}

- (void)setIsLoaded:(BOOL)loaded {
    if (loaded) {
        // XXX: do we really want to do this here?
        if ([self isLoading]) [self cancelLoading];
        
        [self clearLoadingState:kHNObjectLoadingStateUnloaded];
        [self clearLoadingState:kHNObjectLoadingStateNotLoaded];
        [self addLoadingState:kHNObjectLoadingStateLoaded];
    } else {
        [self clearLoadingState:kHNObjectLoadingStateLoaded];
        [self addLoadingState:kHNObjectLoadingStateUnloaded];
    }
}

- (BOOL)isLoading {
    return [self hasLoadingState:kHNObjectLoadingStateLoadingAny];
}
            
- (void)finishLoadingWithResponse:(NSDictionary *)response error:(NSError *)error {
    // overridden in subclasses
}

- (void)_clearRequest {
    if ([apiRequest isLoading]) [apiRequest cancelRequest];
    [apiRequest release];
    apiRequest = nil;
    
    [self clearLoadingState:kHNObjectLoadingStateLoadingAny];
}

- (void)request:(HNAPIRequest *)request completedWithResponse:(NSDictionary *)response error:(NSError *)error {
    [self finishLoadingWithResponse:response error:error];
    
    // note: don't move this downwards, bad things will happen
    [self _clearRequest];
    
    if (error == nil) {
        [self setIsLoaded:YES];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHNObjectFailedLoadingNotification object:self];
    }
}

- (void)beginLoadingWithState:(HNObjectLoadingState)state_ {
    [self addLoadingState:state_];
    
    NSDictionary *info = [self infoDictionary];
    NSDictionary *parameters = [[self class] parametersForURLWithIdentifier:identifier infoDictionary:info];
    NSString *path = [[self class] pathForURLWithIdentifier:identifier infoDictionary:info];
    
    apiRequest = [[HNAPIRequest alloc] initWithTarget:self action:@selector(request:completedWithResponse:error:)];
    [apiRequest performRequestWithPath:path parameters:parameters];
}

- (void)cancelLoading {
    [self _clearRequest];
}

- (void)beginLoading {
    // Loading multiple times at once just makes no sense.
    if ([self isLoading]) return;
    
    if ([self isLoaded]) {
        [self beginLoadingWithState:kHNObjectLoadingStateLoadingReload];
    } else {
        [self beginLoadingWithState:kHNObjectLoadingStateLoadingInitial];
    }
}

@end
