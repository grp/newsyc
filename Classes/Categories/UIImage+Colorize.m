//
//  UIImage+Colorize.m
//  newsyc
//
//  Created by Grant Paul on 3/9/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "UIImage+Colorize.h"

@implementation UIImage (Colorize)

- (UIImage *)imageTintedToColor:(UIColor *)color {
    UIGraphicsBeginImageContext([self size]);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // flip to UIKit coordinates
    CGContextTranslateCTM(context, 0, [self size].height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, [self size].width, [self size].height);
    CGContextDrawImage(context, rect, [self CGImage]);
    
    [color setFill];
    CGContextClipToMask(context, rect, [self CGImage]);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    UIImage *colored = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return colored;
}

@end
