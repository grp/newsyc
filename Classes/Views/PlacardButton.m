//
//  PlacardButton.m
//  newsyc
//
//  Created by Grant Paul on 3/29/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "PlacardButton.h"

@implementation PlacardButton

+ (UIImage *)_normalImage {
    UIImage *image = [UIImage imageNamed:@"UIPlacardButtonBkgnd.png"];
    return [image stretchableImageWithLeftCapWidth:8 topCapHeight:22];
}

+ (UIImage *)_pressedImage {
    UIImage *image = [UIImage imageNamed:@"UIPlacardButtonPressedBkgnd.png"];
    return [image stretchableImageWithLeftCapWidth:8 topCapHeight:22];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setBackgroundImage:[[self class] _normalImage] forState:UIControlStateNormal];
        [self setBackgroundImage:[[self class] _pressedImage] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [[self titleLabel] setFont:[UIFont boldSystemFontOfSize:14.0f]];
    }
    
    return self;
}

@end
