//
//  CommentTableCell.m
//  newsyc
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"

#import "CommentTableCell.h"

#import "NSString+Tags.h"
#import "NSString+Entities.h"
#import "NSAttributedString+HTML.h"

#import "DTCoreTextLayouter.h"
#import "DTLinkButton.h"
#import "DTAttributedTextContentView.h"

@implementation CommentTableCell
@synthesize comment, indentationLevel, delegate, expanded;

- (id)initWithReuseIdentifier:(NSString *)identifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier])) {
        [contentView setBackgroundColor:[UIColor whiteColor]];
        
        CALayer *layer = [contentView layer];
        [layer setContentsGravity:kCAGravityBottomLeft];
        [layer setNeedsDisplayOnBoundsChange:YES];
        
        toolbarView = [[EntryActionsView alloc] initWithFrame:CGRectZero];
        [toolbarView setTintColor:[UIColor blackColor]];
        [toolbarView sizeToFit];
        
        CGRect toolbarFrame = [toolbarView frame];
        toolbarFrame.origin.y = [self bounds].size.height;
        toolbarFrame.size.width = [self bounds].size.width;
        [toolbarView setFrame:toolbarFrame];
        [toolbarView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        
        [self addSubview:toolbarView];
        [self setExpanded:NO];
        
        textView = [[DTAttributedTextView alloc] init];
        [textView setTextDelegate:self];
        [[textView contentView] setEdgeInsets:UIEdgeInsetsZero];
        [contentView addSubview:textView];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapFromRecognizer:)];
        [tapRecognizer setNumberOfTapsRequired:2];
        [tapRecognizer setDelaysTouchesBegan:YES];
        [contentView addGestureRecognizer:[tapRecognizer autorelease]];
    }
    
    return self;
}

- (void)setExpanded:(BOOL)expanded_ {
    expanded = expanded_;
    
    if (expanded) {
        CGRect toolbarFrame = [toolbarView frame];
        toolbarFrame.origin.y = [self bounds].size.height - toolbarFrame.size.height;
        toolbarFrame.size.width = [self bounds].size.width;
        [toolbarView setFrame:toolbarFrame];
    } else {
        CGRect toolbarFrame = [toolbarView frame];
        toolbarFrame.origin.y = [self bounds].size.height;
        toolbarFrame.size.width = [self bounds].size.width;
        [toolbarView setFrame:toolbarFrame];
    }
}

- (void)setDelegate:(id<CommentTableCellDelegate>)delegate_ {
    delegate = delegate_;
    
    [toolbarView setDelegate:delegate];
}

- (void)dealloc {
    [comment release];
    [textView release];
    [toolbarView release];
    
    [super dealloc];
}

+ (NSAttributedString *)attributedStringForComment:(HNEntry *)comment {
    NSString *body = [comment body];
    NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString *attributed = [[NSAttributedString alloc] initWithHTML:data baseURL:kHNWebsiteURL documentAttributes:NULL];

    return [attributed autorelease];
}

- (void)setComment:(HNEntry *)comment_ {
    [comment autorelease];
    comment = [comment_ retain];
    
    NSAttributedString *attributed = [[self class] attributedStringForComment:comment];
    [textView setAttributedString:attributed];
    
    [toolbarView setEntry:comment_];
    
    [self setNeedsDisplay];
}

- (void)setIndentationLevel:(int)level {
    indentationLevel = level;
    
    [self setNeedsDisplay];
}

+ (UIFont *)userFont {
    return [UIFont boldSystemFontOfSize:13.0f];
}

+ (UIFont *)dateFont {
    return [UIFont systemFontOfSize:13.0f];
}

+ (UIFont *)subtleFont {
    return [UIFont systemFontOfSize:13.0f];
}

+ (BOOL)entryShowsPoints:(HNEntry *)entry {
    // Re-enable this for everyone if comment score viewing is re-enabled.
    return [entry submitter] == [[HNSession currentSession] user];
}

+ (CGFloat)bodyHeightForComment:(HNEntry *)comment withWidth:(CGFloat)width indentationLevel:(int)indentationLevel {
    width -= (2 * 8.0f);
    width -= (indentationLevel * 15.0f);
    
    NSAttributedString *attributed = [self attributedStringForComment:comment];
    DTCoreTextLayouter *layouter = [[DTCoreTextLayouter alloc] initWithAttributedString:attributed];
    CGFloat height = [layouter suggestedFrameSizeToFitEntireStringConstraintedToWidth:width].height;
    
    return height;
}

+ (CGFloat)heightForEntry:(HNEntry *)entry withWidth:(CGFloat)width expanded:(BOOL)expanded indentationLevel:(int)indentationLevel {
    CGFloat height = [self bodyHeightForComment:entry withWidth:width indentationLevel:indentationLevel] + 30.0f;
    if ([self entryShowsPoints:entry] || ([entry children] > 0)) height += 14.0f;
    if (expanded) height += 44.0f;
    return height;
}

- (void)drawContentView:(CGRect)rect {
    CGRect bounds = [self bounds];
    bounds.origin.x += (indentationLevel * 15.0f);
    
    CGSize offsets = CGSizeMake(8.0f, 4.0f);
    
    NSString *user = [[comment submitter] identifier];
    NSString *date = [comment posted];
    NSString *points = [comment points] == 1 ? @"1 point" : [NSString stringWithFormat:@"%d points", [comment points]];
    NSString *comments = [comment children] == 0 ? @"" : [comment children] == 1 ? @"1 reply" : [NSString stringWithFormat:@"%d replies", [comment children]];
    
    [[UIColor blackColor] set];
    [user drawAtPoint:CGPointMake(bounds.origin.x + offsets.width, offsets.height) withFont:[[self class] userFont]];
    
    [[UIColor lightGrayColor] set];
    CGFloat datewidth = [date sizeWithFont:[[self class] dateFont]].width;
    [date drawAtPoint:CGPointMake(bounds.size.width - datewidth - offsets.width, offsets.height) withFont:[[self class] dateFont]];
    
    if ([[comment body] length] > 0) {
        CGRect bodyrect;
        bodyrect.size.height = [[self class] bodyHeightForComment:comment withWidth:bounds.size.width indentationLevel:indentationLevel];
        bodyrect.size.width = bounds.size.width - bounds.origin.x - offsets.width - offsets.width;
        bodyrect.origin.x = bounds.origin.x + offsets.width;
        bodyrect.origin.y = offsets.height + 19.0f;
        [textView setFrame:bodyrect];
    } else {
        [textView setFrame:CGRectZero];
    }
    
    [[UIColor grayColor] set];
    CGRect pointsrect;
    pointsrect.size.height = [points sizeWithFont:[[self class] subtleFont]].height;
    pointsrect.size.width = (bounds.size.width + bounds.origin.x) / 2 - offsets.width * 2;
    pointsrect.origin.x = bounds.origin.x + offsets.width;
    pointsrect.origin.y = bounds.size.height - offsets.height - pointsrect.size.height;
    if ([[self class] entryShowsPoints:comment])
          [points drawInRect:pointsrect withFont:[[self class] subtleFont] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
    
    [[UIColor grayColor] set];
    CGRect commentsrect;
    commentsrect.size.height = [comments sizeWithFont:[[self class] subtleFont]].height;
    commentsrect.size.width = (bounds.size.width - bounds.origin.x) / 2 - offsets.width * 2;
    commentsrect.origin.x = bounds.size.width - (bounds.size.width - bounds.origin.x) / 2 + offsets.width;
    commentsrect.origin.y = bounds.size.height - offsets.height - commentsrect.size.height;
}

#pragma mark - Links

- (void)prepareForReuse {
    savedURL = nil;
    
    [super prepareForReuse];
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
	if ([delegate respondsToSelector:@selector(commentTableCell:selectedURL:)]) {
        [delegate commentTableCell:self selectedURL:[button url]];
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

- (void)doubleTapFromRecognizer:(UITapGestureRecognizer *)recognizer {
    if ([delegate respondsToSelector:@selector(commentTableCellDoubleTapped:)])
        [delegate commentTableCellDoubleTapped:self];
}

@end
