//
//  HNObjectCache.h
//  newsyc
//
//  Created by Grant Paul on 7/15/12.
//
//

#import "HNObject.h"

@interface HNObjectCache : NSObject

+ (void)addObjectToCache:(HNObject *)object_;
+ (HNObject *)objectFromCacheWithClass:(Class)cls_ identifier:(id)identifier_ infoDictionary:(NSDictionary *)info;

@end
