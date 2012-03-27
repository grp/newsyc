//
//  ActivityIndicatorItem.h
//  newsyc
//
//  Created by Grant Paul on 4/16/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "BarButtonItem.h"

#define kActivityIndicatorItemStandardSize CGSizeMake(20, 20)

@interface ActivityIndicatorItem : BarButtonItem {
    UIActivityIndicatorView *spinner;
    UIView *container;
}

@property (nonatomic, readonly) UIActivityIndicatorView *spinner;

- (id)initWithSize:(CGSize)size;

@end
