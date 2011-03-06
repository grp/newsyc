//
//  CommentDetailsHeaderView.m
//  Orangey
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNKit.h"

#import "CommentDetailsHeaderView.h"

@implementation CommentDetailsHeaderView

+ (CGSize)offsets {
    return CGSizeMake(8.0f, 4.0f);
}

+ (UIFont *)titleFont {
    return [UIFont systemFontOfSize:12.0f];
}

+ (UIFont *)subtleFont {
    return [UIFont systemFontOfSize:11.0f];
}

+ (CGFloat)heightForEntry:(HNEntry *)entry withWidth:(CGFloat)width {
    return [self offsets].height + [[entry body] sizeWithFont:[self titleFont] constrainedToSize:CGSizeMake(width - ([self offsets].width * 2), 400.0f) lineBreakMode:UILineBreakModeWordWrap].height + 30.0f + [self offsets].height;
}

- (void)drawRect:(CGRect)rect {
    CGSize bounds = [self bounds].size;
    CGSize offsets = [[self class] offsets];
    
    NSString *title = [entry body];
    NSString *date = [entry posted];
    NSString *points = [entry points] == 1 ? @"1 point" : [NSString stringWithFormat:@"%d points", [entry points]];
    
    [[UIColor whiteColor] set];
    UIRectFill([self bounds]);
    
    CGRect titlerect;
    titlerect.origin.y = offsets.height + 8.0f;
    titlerect.origin.x = offsets.width;
    titlerect.size.height = [[self class] heightForEntry:entry withWidth:bounds.width];
    titlerect.size.width = bounds.width - (offsets.width * 2);
    
    [[UIColor blackColor] set];
    [title drawInRect:titlerect withFont:[[self class] titleFont]];
    
    [[UIColor grayColor] set];
    CGFloat subtitleOffset = bounds.height - offsets.height;
    CGSize dateSize = [date sizeWithFont:[[self class] subtleFont]];
    CGSize pointsSize = [points sizeWithFont:[[self class] subtleFont]];
    [points drawAtPoint:CGPointMake(offsets.width, subtitleOffset - pointsSize.height) withFont:[[self class] subtleFont]];
    [date drawAtPoint:CGPointMake(bounds.width - offsets.width - dateSize.width, subtitleOffset - dateSize.height) withFont:[[self class] subtleFont]];
    
    [super drawRect:rect];
}

@end
