//
//  SubmissionTableCell.m
//  newsyc
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"
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
    [submission autorelease];
    submission = [submission_ retain];
    
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
    CGSize titlesize = [[entry title] sizeWithFont:[self titleFont] constrainedToSize:CGSizeMake(width - 16.0f, 200.0f) lineBreakMode:UILineBreakModeWordWrap];
    return titlesize.height + 45.0f;
}

- (void)drawContentView:(CGRect)rect {
    CGSize bounds = [self bounds].size;
    CGSize offsets = CGSizeMake(8.0f, 4.0f);
    
    NSString *user = [[submission submitter] identifier];
    NSString *date = [submission posted];
    NSString *site = [[submission destination] host];
    if ([submission body] != nil) site = @""; // don't show URLs for self posts
    NSString *point = [submission points] == 1 ? @"1 point" : [NSString stringWithFormat:@"%d points", [submission points]];
    NSString *comment = [submission children] == 0 ? @"no comments" : [submission children] == 1 ? @"1 comment" : [NSString stringWithFormat:@"%d comments", [submission children]];
    NSString *points = [NSString stringWithFormat:@"%@ • %@", point, comment];
    NSString *title = [[submission title] stringByDecodingHTMLEntities];
    
    if ([self isHighlighted] || [self isSelected]) [[UIColor whiteColor] set];
    
    if (!([self isHighlighted] || [self isSelected])) [[UIColor grayColor] set];
    [user drawAtPoint:CGPointMake(offsets.width, offsets.height) withFont:[[self class] userFont]];
    
    if (!([self isHighlighted] || [self isSelected])) [[UIColor lightGrayColor] set];
    CGFloat datewidth = [date sizeWithFont:[[self class] dateFont]].width;
    [date drawAtPoint:CGPointMake(bounds.width - datewidth - offsets.width, offsets.height) withFont:[[self class] dateFont]];
    
    if (!([self isHighlighted] || [self isSelected])) [[UIColor blackColor] set];
    [title drawInRect:CGRectMake(offsets.width, offsets.height + 19.0f, bounds.width - (2 * offsets.width), bounds.height - 45.0f) withFont:[[self class] titleFont] lineBreakMode:UILineBreakModeWordWrap];
    
    if (!([self isHighlighted] || [self isSelected])) [[UIColor grayColor] set];
    CGRect pointsrect;
    pointsrect.size.height = [points sizeWithFont:[[self class] subtleFont]].height;
    pointsrect.size.width = (bounds.width / 2) * 1.1 - offsets.width * 2;
    pointsrect.size.width = floorf(pointsrect.size.width);
    pointsrect.origin = CGPointMake(offsets.width, bounds.height - offsets.height - pointsrect.size.height);
    [points drawInRect:pointsrect withFont:[[self class] subtleFont] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
    
    if (!([self isHighlighted] || [self isSelected])) [[UIColor lightGrayColor] set];
    CGRect siterect;
    siterect.size.height = [site sizeWithFont:[[self class] subtleFont]].height;
    siterect.size.width = (bounds.width / 2) * 0.9 - offsets.width * 2;
    siterect.size.width = floorf(siterect.size.width);
    siterect.origin = CGPointMake(bounds.width - offsets.width - siterect.size.width, bounds.height - offsets.height - siterect.size.height);
    [site drawInRect:siterect withFont:[[self class] subtleFont] lineBreakMode:UILineBreakModeHeadTruncation alignment:UITextAlignmentRight];
}

- (void)dealloc {
    [submission release];
    
    [super dealloc];
}

@end
