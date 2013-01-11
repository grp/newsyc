//
//  OrangeTableView.m
//  newsyc
//
//  Created by Grant Paul on 3/26/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "OrangeTableView.h"
#import "UIColor+Orange.h"

@implementation OrangeTableView
@synthesize orange;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame style:UITableViewStyleGrouped])) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        orangeBackgroundView = [[UIView alloc] initWithFrame:[self bounds]];
        [orangeBackgroundView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [orangeBackgroundView setBackgroundColor:[UIColor paleOrangeColor]];
        
        tableBackgroundView = [[UITableView alloc] initWithFrame:[self bounds] style:UITableViewStyleGrouped];
        [tableBackgroundView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    }
    
    return self;
}

- (void)setOrange:(BOOL)orange_ {
    orange = orange_;
    
    if (orange) {
        [self setBackgroundView:orangeBackgroundView];
    } else {
        [self setBackgroundView:tableBackgroundView];
    }
}

@end
