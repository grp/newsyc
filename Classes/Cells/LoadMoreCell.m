//
//  LoadMoreCell.m
//  newsyc
//
//  Created by Grant Paul on 3/25/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "LoadMoreCell.h"

@implementation LoadMoreCell
@synthesize button;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        button = [[LoadMoreButton alloc] initWithFrame:[self bounds]];
        [button setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self addSubview:button];
    }
    
    return self;
}

- (void)dealloc {
    [button release];
    
    [super dealloc];
}

@end
