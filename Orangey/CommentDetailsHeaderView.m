//
//  CommentDetailsHeaderView.m
//  Orangey
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DTAttributedTextView.h"
#import "DTLinkButton.h"
#import "NSAttributedString+HTML.h"

#import "HNKit.h"

#import "CommentDetailsHeaderView.h"

@implementation CommentDetailsHeaderView

- (void)dealloc {
    [textView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        textView = [[DTAttributedTextView alloc] init];
        [textView setTextDelegate:self];
        [self addSubview:textView];
    }
    
    return self;
}

+ (UIFont *)titleFont {
    return [UIFont systemFontOfSize:12.0f];
}

+ (UIFont *)subtleFont {
    return [UIFont systemFontOfSize:11.0f];
}

- (CGFloat)suggestedHeightWithWidth:(CGFloat)width {
    CGSize offsets = [[self class] offsets];
    CGFloat height = [[textView contentView] sizeThatFits:CGSizeMake(width - offsets.width, 0)].height;
    
    return offsets.height + height + 16.0f + offsets.height;
}

- (void)setEntry:(HNEntry *)entry_ {
    [super setEntry:entry_];
    
    NSString *body = [entry body];
    NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString *attributed = [[NSAttributedString alloc] initWithHTML:data baseURL:kHNWebsiteURL documentAttributes:NULL];
    [textView setAttributedString:[attributed autorelease]];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGSize bounds = [self bounds].size;
    CGSize offsets = [[self class] offsets];
    
    NSString *date = [entry posted];
    NSString *points = [entry points] == 1 ? @"1 point" : [NSString stringWithFormat:@"%d points", [entry points]];
    
    CGRect titlerect;
    titlerect.origin.y = offsets.height;
    titlerect.origin.x = offsets.width / 2;
    titlerect.size.width = bounds.width - offsets.width;
    titlerect.size.height = [[textView contentView] sizeThatFits:CGSizeMake(titlerect.size.width, 0)].height;
    [textView setFrame:titlerect];
    
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

- (UIView *)attributedTextView:(DTAttributedTextView *)attributedTextView viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame {
	NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:NULL];
	NSURL *link = [attributes objectForKey:@"DTLink"];
	
	if (link != nil) {
		DTLinkButton *button = [[[DTLinkButton alloc] initWithFrame:frame] autorelease];
		[button setUrl:link];
		[button setAlpha:0.4f];
        
		[button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
		UILongPressGestureRecognizer *longPress = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(linkLongPressed:)] autorelease];
		[button addGestureRecognizer:longPress];
        
		return button;
	}
	
	return nil;
}

- (void)linkPushed:(DTLinkButton *)button {
	if ([delegate respondsToSelector:@selector(detailsHeaderView:selectedURL:)]) {
        [delegate detailsHeaderView:self selectedURL:[button url]];
    }
}

- (void)actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(NSInteger)index {
	if (index == [sheet cancelButtonIndex]) return;
	
    if (index == [sheet firstOtherButtonIndex]) {
        [[UIApplication sharedApplication] openURL:savedURL];
    } else if (index == [sheet firstOtherButtonIndex] + 1) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setURL:savedURL];
        [pasteboard setString:[savedURL absoluteString]];
    }
    
    savedURL = nil;
}

- (void)linkLongPressed:(UILongPressGestureRecognizer *)gesture {
	if (gesture.state == UIGestureRecognizerStateBegan) {
		DTLinkButton *button = (id) [gesture view];
        [button setHighlighted:NO];
        savedURL = [button url];
		
        UIActionSheet *action = [[[UIActionSheet alloc]
            initWithTitle:[[button url] absoluteString]
            delegate:self
            cancelButtonTitle:@"Cancel"
            destructiveButtonTitle:nil
            otherButtonTitles:@"Open in Safari", @"Copy Link", nil
        ] autorelease];
        [action showFromRect:[button frame] inView:[button superview] animated:YES];
    }
}

@end
