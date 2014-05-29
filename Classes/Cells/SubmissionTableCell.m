//
//  SubmissionTableCell.m
//  newsyc
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import <HNKit/HNKit.h>
#import "NSString+Entities.h"

#import "SubmissionTableCell.h"

@implementation SubmissionTableCell
@synthesize submission;

- (id)initWithReuseIdentifier:(NSString *)identifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier])) {
        [contentView setBackgroundColor:[UIColor whiteColor]];
        
        CALayer *layer = [contentView layer];
        [layer setContentsGravity:kCAGravityTopLeft];
        [layer setNeedsDisplayOnBoundsChange:YES];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    [self setNeedsDisplay];
}

- (void)setSubmission:(HNEntry *)submission_ {
    submission = submission_;
    
    [self setNeedsDisplay];
}

+ (UIFont *)titleFont {
    return [UIFont boldSystemFontOfSize:15.0f];
}

+ (UIFont *)userFont {
    return [UIFont systemFontOfSize:13.0f];
}

+ (UIFont *)dateFont {
    return [UIFont systemFontOfSize:13.0f];
}

+ (UIFont *)subtleFont {
    return [UIFont systemFontOfSize:13.0f];
}

+ (CGFloat)heightForEntry:(HNEntry *)entry withWidth:(CGFloat)width {
    CGFloat constrainedWidth = width - 16.0;

    if ([self instancesRespondToSelector:@selector(separatorInset)]) {
        // On iOS 7, the left inset is 17 - 8 = 7.
        constrainedWidth -= 7.0;
    }

    CGSize titlesize = [[entry title] sizeWithFont:[self titleFont] constrainedToSize:CGSizeMake(constrainedWidth, 200.0f) lineBreakMode:NSLineBreakByWordWrapping];
    return ceilf(titlesize.height) + 45.0f;
}

- (void)drawContentView:(CGRect)rect {
    BOOL highlighted = [self isHighlighted] || [self isSelected];

    if (!highlighted) {
        [[UIColor whiteColor] set];
        UIRectFill(rect);
    }

    CGSize bounds = [self bounds].size;
    UIEdgeInsets offsets = UIEdgeInsetsMake(4.0, 8.0, 4.0, 8.0);

    if ([self respondsToSelector:@selector(separatorInset)]) {
        offsets.left = [self separatorInset].left;
        highlighted = NO;
    }

    NSString *user = [[submission submitter] identifier];
    NSString *date = [submission posted];
    NSString *site = [[submission destination] host];
    if ([submission body] != nil) site = @""; // don't show URLs for self posts
    NSString *point = [submission points] == 1 ? @"1 point" : [NSString stringWithFormat:@"%ld points", (long)[submission points]];
    NSString *comment = [submission children] == 0 ? @"no comments" : [submission children] == 1 ? @"1 comment" : [NSString stringWithFormat:@"%ld comments", (long)[submission children]];
    NSString *points = [NSString stringWithFormat:@"%@ • %@", point, comment];
    NSString *title = [[submission title] stringByDecodingHTMLEntities];
    
    if (highlighted) [[UIColor whiteColor] set];
    
    if (!highlighted) [[UIColor grayColor] set];
    [user drawAtPoint:CGPointMake(offsets.left, offsets.top) withFont:[[self class] userFont]];
    
    if (!highlighted) [[UIColor lightGrayColor] set];
    CGFloat datewidth = [date sizeWithFont:[[self class] dateFont]].width;
    [date drawAtPoint:CGPointMake(bounds.width - datewidth - offsets.right, offsets.top) withFont:[[self class] dateFont]];
    
    if (!highlighted) [[UIColor blackColor] set];
    [title drawInRect:CGRectMake(offsets.left, offsets.top + 19.0f, bounds.width - offsets.left - offsets.right, bounds.height - 45.0f) withFont:[[self class] titleFont] lineBreakMode:NSLineBreakByWordWrapping];
    
    if (!highlighted) [[UIColor grayColor] set];
    CGRect pointsrect;
    pointsrect.size.height = [points sizeWithFont:[[self class] subtleFont]].height;
    pointsrect.size.width = (bounds.width / 2) * 1.1 - offsets.left - offsets.right;
    pointsrect.size.width = floorf(pointsrect.size.width);
    pointsrect.origin = CGPointMake(offsets.left, bounds.height - offsets.bottom - pointsrect.size.height);
    [points drawInRect:pointsrect withFont:[[self class] subtleFont] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
    
    if (!highlighted) [[UIColor lightGrayColor] set];
    CGRect siterect;
    siterect.size.height = [site sizeWithFont:[[self class] subtleFont]].height;
    siterect.size.width = (bounds.width / 2) * 0.9 - offsets.left - offsets.right;
    siterect.size.width = floorf(siterect.size.width);
    siterect.origin = CGPointMake(bounds.width - offsets.right - siterect.size.width, bounds.height - offsets.bottom - siterect.size.height);
    [site drawInRect:siterect withFont:[[self class] subtleFont] lineBreakMode:NSLineBreakByTruncatingHead alignment:NSTextAlignmentRight];
}


@end
