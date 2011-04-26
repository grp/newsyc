//
//  FloatingDelegateController.h
//  newsyc
//
//  Created by Grant Paul on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@interface FloatingDelegateController : NSObject {
    NSMutableDictionary *delegates;
}

+ (id)sharedInstance;
- (void)addObject:(id)object withOwner:(id)owner;
- (void)clearObjectsForOwner:(id)owner;

@end
