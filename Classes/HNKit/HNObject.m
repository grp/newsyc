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

@interface HNObjectCache : NSObject {
    Class cls;
    id identifier;
    NSDictionary *info;
}

@property (nonatomic, retain, readonly) HNObject *object;

@end

@implementation HNObjectCache
@synthesize object;

+ (NSCache *)cache {
    static NSCache *objectCache = nil;
    if (objectCache == nil) objectCache = [[NSCache alloc] init];
    return objectCache;
}

+ (void)initialize {
    // inititalize cache
    [self cache];
}

- (id)initWithClass:(Class)cls_ identifier:(id)identifier_ infoDictionary:(NSDictionary *)info_ {
    if ((self = [super init])) {
        cls = cls_;
        identifier = [identifier_ copy];
        info = [info_ copy];
    }
    
    return self;
}

- (void)dealloc {
    [identifier release];
    [info release];
    
    [super dealloc];
}

+ (id)objectCacheWithClass:(Class)cls_ identifier:(id)identifier_ infoDictionary:(NSDictionary *)info {
    return [[[self alloc] initWithClass:cls_ identifier:identifier_ infoDictionary:info] autorelease];
}

+ (void)addObjectToCache:(HNObject *)object_ {
    HNObjectCache *key = [self objectCacheWithClass:[object_ class] identifier:[object_ identifier] infoDictionary:[object_ infoDictionary]];
    NSCache *cache = [self cache];
    [cache setObject:object_ forKey:key];
}

+ (HNObject *)objectFromCacheWithClass:(Class)cls_ identifier:(id)identifier_ infoDictionary:(NSDictionary *)info {
    HNObjectCache *key = [self objectCacheWithClass:cls_ identifier:identifier_ infoDictionary:info];
    NSCache *cache = [self cache];
    HNObject *cached = [cache objectForKey:key];
    return cached;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithClass:cls identifier:identifier infoDictionary:info];
}

- (BOOL)isEqual:(id)object_ {
    // XXX: are hash collisions a likely issue here?
    return [self hash] == [object_ hash];
}

- (NSUInteger)hash {
    // XXX: does this increase the chance of collisions?
    return [cls hash] ^ [identifier hash] ^ [info hash];
}

@end

@implementation HNObject
@synthesize identifier, loadingState, URL=url, delegate;

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
            
- (NSString *)_additionalDescription {
    return @"";
}
            
- (NSString *)description {
    NSString *other = nil;
    if ([self isLoaded]) other = [self _additionalDescription];
    else other = @"[not loaded]";
    
    NSString *identifier_ = [NSString stringWithFormat:@" identifier=%@", identifier];
    if (identifier == nil) identifier_ = @"";
    
    return [NSString stringWithFormat:@"<%@:%p %@ %@>", [self class], self, identifier_, other];
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
    } else if ((state_ & kHNObjectLoadingStateLoadingAny) > 0) {
        if ([delegate respondsToSelector:@selector(objectStartedLoading:)]) [delegate objectStartedLoading:self];
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
    
    // note: don't move this downwards, bad things will happen
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
    if ([self isLoaded]) {
        [self _beginLoadingWithState:kHNObjectLoadingStateLoadingReload];
    } else {
        [self _beginLoadingWithState:kHNObjectLoadingStateLoadingInitial];
    }
}

@end
