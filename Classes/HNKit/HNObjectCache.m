//
//  HNObjectCache.m
//  newsyc
//
//  Created by Grant Paul on 7/15/12.
//
//

#import "HNObjectCache.h"

@interface HNObjectCacheKey : NSObject <NSCopying> {
    Class cls;
    id identifier;
    NSDictionary *info;
}

@end

@implementation HNObjectCacheKey

#pragma mark - Lifecycle

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

#pragma mark - Properties

- (Class)objectClass {
    return cls;
}

- (id)objectIdentifier {
    return identifier;
}

- (NSDictionary *)objectInfoDictionary {
    return info;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithClass:cls identifier:identifier infoDictionary:info];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object_ {
    BOOL classes = cls == [object_ objectClass];
    BOOL identifiers = [identifier isEqual:[object_ objectIdentifier]];
    BOOL infos = [info isEqualToDictionary:[object_ objectInfoDictionary]] || (info == nil && [object_ objectInfoDictionary] == nil);

    return classes && identifiers && infos;
}

- (NSUInteger)hash {
    return [cls hash] ^ [identifier hash] ^ [info hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p identifier=%@ info=%p>", [self class], self, identifier, info];
}

@end

@implementation HNObjectCache

+ (NSMutableDictionary *)cacheDictionary {
    static NSMutableDictionary *objectCache = nil;
    if (objectCache == nil) objectCache = [[NSMutableDictionary alloc] init];
    return objectCache;
}

+ (void)initialize {
    static BOOL initialized = NO;

    if (!initialized) {
        // inititalize the cache
        [self cacheDictionary];

        initialized = YES;
    }
}

+ (void)addObjectToCache:(HNObject *)object_ {
    HNObjectCacheKey *key = [HNObjectCacheKey objectCacheWithClass:[object_ class] identifier:[object_ identifier] infoDictionary:[object_ infoDictionary]];

    NSMutableDictionary *cache = [self cacheDictionary];
    [cache setObject:object_ forKey:key];
}

+ (HNObject *)objectFromCacheWithClass:(Class)cls_ identifier:(id)identifier_ infoDictionary:(NSDictionary *)info {
    HNObjectCacheKey *key = [HNObjectCacheKey objectCacheWithClass:cls_ identifier:identifier_ infoDictionary:info];

    NSMutableDictionary *cache = [self cacheDictionary];
    return [cache objectForKey:key];
}

@end
