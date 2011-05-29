//
//  UIApplication+ActivityIndicator.m
//  newsyc
//
//  Created by Grant Paul on 5/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIApplication+ActivityIndicator.h"

@implementation UIApplication (ActivityIndicator)

- (void)_updateNetworkActivityIndicator:(BOOL)visible {
    static int count = 0;
    
    if (visible) count += 1;
    else count -= 1;
    
    [self setNetworkActivityIndicatorVisible:(count > 0)];
}


- (void)retainNetworkActivityIndicator {
    [self _updateNetworkActivityIndicator:YES];
}

- (void)releaseNetworkActivityIndicator {
    [self _updateNetworkActivityIndicator:NO];
}

@end
