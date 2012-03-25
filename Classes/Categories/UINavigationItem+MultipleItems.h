//
//  UIBarButtonItem+MultipleItems.h
//  newsyc
//
//  Created by Grant Paul on 3/23/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UINavigationItemPositionLeft,
    UINavigationItemPositionRight
} UINavigationItemPosition;

@interface UINavigationItem (MultipleItems)

- (void)addLeftBarButtonItem:(UIBarButtonItem *)item atPosition:(UINavigationItemPosition)position;
- (void)addRightBarButtonItem:(UIBarButtonItem *)item atPosition:(UINavigationItemPosition)position;

- (void)removeLeftBarButtonItem:(UIBarButtonItem *)item;
- (void)removeRightBarButtonItem:(UIBarButtonItem *)item;
- (void)removeBarButtonItem:(UIBarButtonItem *)item;

@end
