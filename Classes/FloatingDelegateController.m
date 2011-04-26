//
//  FloatingDelegateController.m
//  newsyc
//
//  Created by Grant Paul on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FloatingDelegateController.h"

@implementation FloatingDelegateController

+ (id)sharedInstance {
    static id sharedController = nil;
    if (sharedController == nil) sharedController = [[self alloc] init];
    return sharedController;
}

+ (void)initialize {
    [self sharedInstance];
}

- (id)init {
    if ((self = [super init])) {
        delegates = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [delegates release];
    [super dealloc];
}

- (NSValue *)valueForOwner:(id)owner {
    NSValue *value = [NSValue valueWithPointer:owner];
    return value;
}

- (NSValue *)valueForObject:(id)object {
    NSValue *value = [NSValue valueWithPointer:object];
    return value;
}

- (id)objectWithValue:(NSValue *)value {
    return (id) [value pointerValue];
}

- (void)addObject:(id)object withOwner:(id)owner {
    NSAssert([object delegate] == object, @"Delegate for object %@ does not match owner %@, instead is %@.", object, owner, [object delegate]);
    
    NSValue *key = [self valueForOwner:owner];
    NSValue *value = [self valueForObject:object];
    NSMutableArray *objects = nil;
    
    if ([delegates objectForKey:key] == nil) {
        objects = [NSMutableArray array];
        [delegates setObject:objects forKey:key];
    } else {
        objects = [delegates objectForKey:key];
    }
    
    [objects addObject:value];
}

- (void)clearObjectsForOwner:(id)owner {
    NSValue *key = [self valueForOwner:owner];
    NSArray *objects = [delegates objectForKey:key];
    
    for (NSValue *value in objects) {
        id object = [self objectWithValue:value];
        [object setDelegate:nil];
    }
    
    [delegates removeObjectForKey:key];
}

@end
