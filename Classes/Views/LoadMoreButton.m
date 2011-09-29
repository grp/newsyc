//
//  LoadMoreView.m
//  newsyc
//
//  Created by Grant Paul on 9/5/11.
//  Copyright (c) 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "LoadMoreButton.h"

@implementation LoadMoreButton

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        indicatorView = [[LoadingIndicatorView alloc] initWithFrame:[self bounds]];
        [indicatorView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [indicatorView setHidden:YES];
        [indicatorView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:indicatorView];
        
        moreLabel = [[UILabel alloc] initWithFrame:[self bounds]];
        [moreLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [moreLabel setText:@"Load More..."];
        [moreLabel setTextAlignment:UITextAlignmentCenter];
        [moreLabel setTextColor:[UIColor grayColor]];
        [moreLabel setFont:[UIFont systemFontOfSize:17.0f]];
        [self addSubview:moreLabel];
    }
    
    return self;
}

- (void)startLoading {
    [indicatorView setHidden:NO];
    [moreLabel setHidden:YES];
}

- (void)stopLoading {
    [indicatorView setHidden:YES];
    [moreLabel setHidden:NO];
}

- (void)dealloc {
    [indicatorView release];
    [moreLabel release];
    
    [super dealloc];
}

@end
