//
//  SubmissionDetailsHeaderView.m
//  Orangey
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNKit.h"

#import "SubmissionDetailsHeaderView.h"

@implementation SubmissionDetailsHeaderView

- (void)viewPressed:(SubmissionDetailsHeaderView *)view withEvent:(UIEvent *)event {
    if ([delegate respondsToSelector:@selector(submissionDetailsViewWasTapped:)]) {
        [delegate submissionDetailsViewWasTapped:self];
    }
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self addTarget:self action:@selector(viewPressed:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

+ (UIFont *)titleFont {
    return [UIFont boldSystemFontOfSize:17.0f];
}

+ (UIFont *)subtleFont {
    return [UIFont systemFontOfSize:11.0f];
}

- (CGFloat)suggestedHeightWithWidth:(CGFloat)width {
    CGSize offsets = [[self class] offsets];
    CGFloat height = [[entry title] sizeWithFont:[[self class] titleFont] constrainedToSize:CGSizeMake(width - (offsets.width * 2), 400.0f) lineBreakMode:UILineBreakModeWordWrap].height;
    
    return offsets.height + height + 30.0f + offsets.height;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGSize bounds = [self bounds].size;
    CGSize offsets = [[self class] offsets];
    
    NSString *title = [entry title];
    NSString *date = [entry posted];
    NSString *points = [entry points] == 1 ? @"1 point" : [NSString stringWithFormat:@"%d points", [entry points]];
    
    if ([self isHighlighted]) {
        [[UIColor colorWithWhite:0.85f alpha:1.0f] set];
        UIRectFill([self bounds]);
    }
    
    [[UIColor blackColor] set];
    CGRect titlerect;
    titlerect.size.width = bounds.width - (offsets.width * 2);
    titlerect.size.height = [self suggestedHeightWithWidth:bounds.width];
    titlerect.origin.x = offsets.width;
    titlerect.origin.y = offsets.height + 8.0f;
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
