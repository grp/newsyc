//
//  HNObjectCache.m
//  newsyc
//
//  Created by Grant Paul on 7/15/12.
//
//

#import "HNObjectCache.h"

@interface HNObjectCacheKey : NSObject <NSCopying, NSCoding> {
    Class cls;
    id identifier;
    NSDictionary *info;

    HNObject *object;
}

+ (id)objectCacheWithClass:(Class)cls_ identifier:(id)identifier_ infoDictionary:(NSDictionary *)info;
+ (id)objectCacheWithObject:(HNObject *)object;

@property (nonatomic, readonly) Class objectClass;
@property (nonatomic, readonly) id objectIdentifier;
@property (nonatomic, readonly) NSDictionary *objectInfoDictionary;

@property (nonatomic, readonly) HNObject *object;

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

- (id)initWithObject:(HNObject *)object_ {
    if ((self = [super init])) {
        object = [object_ retain];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectLoadedWithNotification:) name:kHNObjectLoadingStateChangedNotification object:object];
        [self save];

        cls = [object class];
        identifier = [[object identifier] copy];
        info = [[object infoDictionary] copy];
    }

    return self;
}

- (void)dealloc {
    [object release];
    [identifier release];
    [info release];

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}

+ (id)objectCacheWithClass:(Class)cls_ identifier:(id)identifier_ infoDictionary:(NSDictionary *)info {
    return [[[self alloc] initWithClass:cls_ identifier:identifier_ infoDictionary:info] autorelease];
}

+ (id)objectCacheWithObject:(HNObject *)object {
    return [[[self alloc] initWithObject:object] autorelease];
}

#pragma mark - Persistence

- (NSString *)path {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return [path stringByAppendingPathComponent:[NSString stringWithFormat:@"object_%@_%@", cls, identifier]];
}

- (void)save {
    NSString *path = [self path];
    NSDictionary *contents = [object contentsDictionary];

    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:contents forKey:@"object"];
    [archiver finishEncoding];
    [data writeToFile:path atomically:YES];
    [archiver release];
}

- (void)load {
    NSString *path = [self path];
    NSData *data = [NSData dataWithContentsOfFile:path];

    if (data == nil) {
        NSLog(@"Unable to load cache key: %@ %@ %@", cls, identifier, info);
        return;
    }

    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *contents = [unarchiver decodeObjectForKey:@"object"];
    [unarchiver finishDecoding];
    [unarchiver release];

    object = [[cls alloc] init];
    [object setURL:[cls generateURLWithIdentifier:identifier infoDictionary:info]];
    [object setIdentifier:identifier];
    [object loadInfoDictionary:info];
    [object loadContentsDictionary:contents];
    [object retain];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectLoadedWithNotification:) name:kHNObjectLoadingStateChangedNotification object:object];
}

- (void)objectLoadedWithNotification:(NSNotification *)notification {
    [self save];
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

- (HNObject *)object {
    if (object != nil) {
        return object;
    } else {
        [self load];

        return object;
    }
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    Class cls_ = NSClassFromString([decoder decodeObjectForKey:@"class"]);
    id identifier_ = [decoder decodeObjectForKey:@"identifier"];
    NSDictionary *info_ = [decoder decodeObjectForKey:@"info"];

    if ((self = [self initWithClass:cls_ identifier:identifier_ infoDictionary:info_])) {

    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:NSStringFromClass(cls) forKey:@"class"];
    [coder encodeObject:identifier forKey:@"identifier"];
    [coder encodeObject:info forKey:@"info"];
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

+ (NSString *)path {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return [path stringByAppendingPathComponent:@"object_cache"];
}

+ (void)save {
    NSString *path = [self path];

    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:[self cache] forKey:@"cache"];
    [archiver finishEncoding];
    [data writeToFile:path atomically:YES];
    [archiver release];
}

+ (void)load {
    NSString *path = [self path];
    NSData *data = [NSData dataWithContentsOfFile:path];

    if (data == nil) {
        NSLog(@"Creating new cache.");
        [self save];
        return;
    }

    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [[self cache] unionSet:[unarchiver decodeObjectForKey:@"cache"]];
    [unarchiver finishDecoding];
    [unarchiver release];
}

+ (NSMutableSet *)cache {
    static NSMutableSet *objectCache = nil;

    if (objectCache == nil) {
        objectCache = [[NSMutableSet alloc] init];

        [self load];
    }

    return objectCache;
}

+ (void)initialize {
    static BOOL initialized = NO;

    if (!initialized) {
        [self cache];

        initialized = YES;
    }
}

+ (void)addObjectToCache:(HNObject *)object_ {
    HNObjectCacheKey *key = [HNObjectCacheKey objectCacheWithObject:object_];
    [[self cache] addObject:key];

    [self save];
}

+ (HNObject *)objectFromCacheWithClass:(Class)cls_ identifier:(id)identifier_ infoDictionary:(NSDictionary *)info {
    HNObjectCacheKey *key = [HNObjectCacheKey objectCacheWithClass:cls_ identifier:identifier_ infoDictionary:info];
    return [[[self cache] member:key] object];
}

@end
