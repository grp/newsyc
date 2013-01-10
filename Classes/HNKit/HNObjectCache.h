//
//  HNObjectCache.h
//  newsyc
//
//  Created by Grant Paul on 7/15/12.
//
//

#import "HNObject.h"

@interface HNObjectCache : NSObject {
    HNSession *session;
    NSMutableDictionary *cacheDictionary;
}

- (id)initWithSession:(HNSession *)session_;

- (BOOL)cacheHasObject:(HNObject *)object;
- (void)addObjectToCache:(HNObject *)object_;
- (HNObject *)objectFromCacheWithClass:(Class)cls_ identifier:(id)identifier_ infoDictionary:(NSDictionary *)info;

- (void)createPersistentCache;
- (void)clearPersistentCache;
- (void)updateObjectFromPersistentCache:(HNObject *)object;
- (void)savePersistentCacheDictionary:(NSDictionary *)dict forObject:(HNObject *)object;

@end
