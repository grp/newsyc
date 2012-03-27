//
//  ActivityIndicatorItem.m
//  newsyc
//
//  Created by Grant Paul on 4/16/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "ActivityIndicatorItem.h"

@implementation ActivityIndicatorItem
@synthesize spinner;

// XXX: this cannot be named -init because -init is called by UIKit itself inside -initWithCustomView:
- (id)initWithSize:(CGSize)size {
    UIView *container_ = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)] autorelease];

    if ((self = [super initWithCustomView:container_])) {
        spinner = [[UIActivityIndicatorView alloc] init];
        [spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [spinner setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
        [spinner startAnimating];
        [spinner sizeToFit];
        
        container = [container_ retain];
        [container addSubview:spinner];
    }
    
    return self;
}

- (void)dealloc {
    [container release];
    [spinner release];
    
    [super dealloc];
}

@end
