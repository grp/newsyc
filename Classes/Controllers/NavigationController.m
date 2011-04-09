//
//  NavigationController.m
//  newsyc
//
//  Created by Grant Paul on 3/29/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "NavigationController.h"

#define kNavigationControllerTintOrange [UIColor colorWithRed:1.0f green:0.4f blue:0.0f alpha:1.0f]

@implementation NavigationController

- (id)init {
    if ((self = [super init])) {
        [[self navigationBar] setTintColor:kNavigationControllerTintOrange];
    }
    
    return self;
}

@end
