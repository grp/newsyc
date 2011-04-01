//
//  SubmissionDetailsHeaderView.m
//  Orangey
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNKit.h"
#import "NSString+Entities.h"

#import "SubmissionDetailsHeaderView.h"

@implementation SubmissionDetailsHeaderView

- (void)viewPressed:(SubmissionDetailsHeaderView *)view withEvent:(UIEvent *)event {
    if ([delegate respondsToSelector:@selector(detailsHeaderView:selectedURL:)]) {
        [delegate detailsHeaderView:self selectedURL:[entry destination]];
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

+ (UIImage *)disclosureImage; {
    return [UIImage imageNamed:@"disclosure.png"];
}

- (CGFloat)suggestedHeightWithWidth:(CGFloat)width {
    CGSize offsets = [[self class] offsets];
    CGFloat height = [[entry title] sizeWithFont:[[self class] titleFont] constrainedToSize:CGSizeMake(width - (offsets.width * 2) - [[[self class] disclosureImage] size].width, 400.0f) lineBreakMode:UILineBreakModeWordWrap].height;
    
    return offsets.height + height + 30.0f + offsets.height;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGSize bounds = [self bounds].size;
    CGSize offsets = [[self class] offsets];
    
    NSString *title = [[entry title] stringByDecodingHTMLEntities];
    NSString *date = [entry posted];
    NSString *points = [entry points] == 1 ? @"1 point" : [NSString stringWithFormat:@"%d points", [entry points]];
    NSString *pointdate = [NSString stringWithFormat:@"%@ • %@", points, date];
    NSString *user = [[entry submitter] identifier];
    UIImage *disclosure = [[self class] disclosureImage];
    
    if ([self isHighlighted]) {
        [[UIColor colorWithWhite:0.85f alpha:1.0f] set];
        UIRectFill([self bounds]);
    }
    
    [[UIColor blackColor] set];
    CGRect titlerect;
    titlerect.size.width = bounds.width - (offsets.width * 3) - [disclosure size].width;
    titlerect.size.height = [[entry title] sizeWithFont:[[self class] titleFont] constrainedToSize:CGSizeMake(titlerect.size.width, 400.0f) lineBreakMode:UILineBreakModeWordWrap].height;
    titlerect.origin.x = offsets.width;
    titlerect.origin.y = offsets.height + 8.0f;
    [title drawInRect:titlerect withFont:[[self class] titleFont]];
    
    [[UIColor grayColor] set];
    CGRect pointsrect;
    pointsrect.size.width = bounds.width / 2 - (offsets.width * 2);
    pointsrect.size.height = [pointdate sizeWithFont:[[self class] subtleFont]].height;
    pointsrect.origin.x = offsets.width;
    pointsrect.origin.y = bounds.height - offsets.height - offsets.height - pointsrect.size.height;
    [pointdate drawInRect:pointsrect withFont:[[self class] subtleFont] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
    
    [[UIColor darkGrayColor] set];
    CGRect userrect;
    userrect.size.width = bounds.width / 2 - (offsets.width * 2);
    userrect.size.height = [user sizeWithFont:[[self class] subtleFont]].height;
    userrect.origin.x = bounds.width / 2 + offsets.width;
    userrect.origin.y = bounds.height - offsets.height - offsets.height - userrect.size.height;
    [user drawInRect:userrect withFont:[[self class] subtleFont] lineBreakMode:UILineBreakModeHeadTruncation alignment:UITextAlignmentRight];
    
    CGRect disclosurerect;
    disclosurerect.size = [disclosure size];
    disclosurerect.origin.x = bounds.width - offsets.width - disclosurerect.size.width;
    disclosurerect.origin.y = titlerect.origin.y + (titlerect.size.height / 2) - (disclosurerect.size.height / 2);
    [disclosure drawInRect:disclosurerect];
}

@end
