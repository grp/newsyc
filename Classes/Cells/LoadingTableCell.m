//
//  LoadingTableCell.m
//  newsyc
//
//  Created by Grant Paul on 5/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadingTableCell.h"


@implementation LoadingTableCell

- (id)initWithReuseIdentifier:(NSString *)identifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier])) {
        [contentView setBackgroundColor:[UIColor whiteColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        indicator = [[LoadingIndicatorView alloc] initWithFrame:[self bounds]];
        [self addSubview:indicator];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [indicator setFrame:[self bounds]];
}

- (void)dealloc {
    [indicator release];
    [super dealloc];
}

@end
