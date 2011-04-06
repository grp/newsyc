//
//  NavigationController.m
//  newsyc
//
//  Created by Grant Paul on 3/29/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "NavigationController.h"

#define kNavigationControllerTintOrange [UIColor colorWithRed:0.9f green:0.3 blue:0.0f alpha:1.0f]

@implementation NavigationController

@synthesize needToShow, toShow;

- (id)init {
    if ((self = [super init])) {
        [[self navigationBar] setTintColor:kNavigationControllerTintOrange];
    }
    needToShow = NO;
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    if(needToShow) {
        [self presentModalViewController:toShow animated:YES];
        needToShow = NO;
    }
}

@end
