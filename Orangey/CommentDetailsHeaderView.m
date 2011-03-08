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

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
    }
    
    return self;
}

+ (UIFont *)titleFont {
    return [UIFont systemFontOfSize:12.0f];
}

+ (UIFont *)subtleFont {
    return [UIFont systemFontOfSize:11.0f];
}

+ (CGFloat)heightForEntry:(HNEntry *)entry withWidth:(CGFloat)width {
    return [self offsets].height + [[entry body] sizeWithFont:[self titleFont] constrainedToSize:CGSizeMake(width - ([self offsets].width * 2), 2000.0f) lineBreakMode:UILineBreakModeWordWrap].height + 30.0f + [self offsets].height;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGSize bounds = [self bounds].size;
    CGSize offsets = [[self class] offsets];
    
    NSString *title = [entry body];
    NSString *date = [entry posted];
    NSString *points = [entry points] == 1 ? @"1 point" : [NSString stringWithFormat:@"%d points", [entry points]];
    
    CGRect titlerect;
    titlerect.origin.y = offsets.height + 8.0f;
    titlerect.origin.x = offsets.width;
    titlerect.size.height = [[self class] heightForEntry:entry withWidth:bounds.width];
    titlerect.size.width = bounds.width - (offsets.width * 2);
    
    [[UIColor blackColor] set];
    [title drawInRect:titlerect withFont:[[self class] titleFont]];
    
    [[UIColor grayColor] set];
    CGRect pointsrect;
    pointsrect.size.width = bounds.width / 2 - (offsets.width * 2);
    pointsrect.size.height = [points sizeWithFont:[[self class] subtleFont]].height;
    pointsrect.origin.x = offsets.width;
    pointsrect.origin.y = bounds.height - offsets.height - pointsrect.size.height;
    [points drawInRect:pointsrect withFont:[[self class] subtleFont] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
    
    [[UIColor grayColor] set];
    CGRect daterect;
    daterect.size.width = bounds.width / 2 - (offsets.width * 2);
    daterect.size.height = [date sizeWithFont:[[self class] subtleFont]].height;
    daterect.origin.x = bounds.width / 2 + offsets.width;
    daterect.origin.y = bounds.height - offsets.height - daterect.size.height;
    [date drawInRect:daterect withFont:[[self class] subtleFont] lineBreakMode:UILineBreakModeHeadTruncation alignment:UITextAlignmentRight];
}

@end
