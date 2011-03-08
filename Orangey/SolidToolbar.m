//
//  SolidToolbar.m
//  Orangey
//
//  Created by Grant Paul on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SolidToolbar.h"

@implementation SolidToolbar

- (void)drawRect:(CGRect)rect {
    [[self tintColor] set];
    UIRectFill(rect);
}

@end
