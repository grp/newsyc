//
//  UIBarButtonItem+MultipleItems.m
//  newsyc
//
//  Created by Grant Paul on 3/23/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "UINavigationItem+MultipleItems.h"

@implementation UINavigationItem (MultipleItems)

- (void)addLeftBarButtonItem:(UIBarButtonItem *)item atPosition:(UINavigationItemPosition)position {
    [self removeBarButtonItem:item];
    
    NSArray *current = [self leftBarButtonItems];
    NSArray *added = nil;
    if (current == nil) current = [NSArray array];
    
    if (position == UINavigationItemPositionLeft) {
        added = [[NSArray arrayWithObject:item] arrayByAddingObjectsFromArray:current];
    } else if (position == UINavigationItemPositionRight) {
        added = [current arrayByAddingObject:item];
    }
    
    [self setLeftBarButtonItems:added];
    
    [self setLeftItemsSupplementBackButton:YES];
}

- (void)addRightBarButtonItem:(UIBarButtonItem *)item atPosition:(UINavigationItemPosition)position {
    [self removeBarButtonItem:item];
    
    NSArray *current = [self rightBarButtonItems];
    NSArray *added = nil;
    if (current == nil) current = [NSArray array];
    
    if (position == UINavigationItemPositionLeft) {
        added = [current arrayByAddingObject:item];
    } else if (position == UINavigationItemPositionRight) {
        added = [[NSArray arrayWithObject:item] arrayByAddingObjectsFromArray:current];
    }
    
    [self setRightBarButtonItems:added];
}

- (void)removeLeftBarButtonItem:(UIBarButtonItem *)item {
    NSMutableArray *current = [[self leftBarButtonItems] mutableCopy];
    [current removeObject:item];
    [current autorelease];
    
    [self setLeftBarButtonItems:current];
}

- (void)removeRightBarButtonItem:(UIBarButtonItem *)item {
    NSMutableArray *current = [[self rightBarButtonItems] mutableCopy];
    [current removeObject:item];
    [current autorelease];
    
    [self setRightBarButtonItems:current];
}

- (void)removeBarButtonItem:(UIBarButtonItem *)item {
    [self removeLeftBarButtonItem:item];
    [self removeRightBarButtonItem:item];
}

@end
