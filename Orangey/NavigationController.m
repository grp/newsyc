//
//  NavigationController.m
//  Orangey
//
//  Created by Grant Paul on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NavigationController.h"

#define kNavigationControllerTintOrange [UIColor colorWithRed:0.9f green:0.3 blue:0.0f alpha:1.0f]

@implementation NavigationController

- (id)init {
    if ((self = [super init])) {
        [[self navigationBar] setTintColor:kNavigationControllerTintOrange];
    }
    
    return self;
}

@end
