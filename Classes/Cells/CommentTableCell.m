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
#import "UIActionSheet+Context.h"

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
        
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFromRecognizer:)];
        [longPressRecognizer setMinimumPressDuration:0.65f];
        [contentView addGestureRecognizer:[longPressRecognizer autorelease]];
    }
    
    return self;
}

- (void)dealloc {
    [comment release];
    [toolbarView release];
    
    [super dealloc];
}

#pragma mark - Setters

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

- (void)setComment:(HNEntry *)comment_ {
    [comment autorelease];
    comment = [comment_ retain];
    
    [toolbarView setEntry:comment_];
    
    [self setNeedsDisplay];
}

- (void)setIndentationLevel:(int)level {
    indentationLevel = level;
    
    [self setNeedsDisplay];
}

#pragma mark - Configuration

+ (UIFont *)userFont {
    return [UIFont boldSystemFontOfSize:14.0f];
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

#pragma mark - Height Calculations

+ (CGFloat)bodyHeightForComment:(HNEntry *)comment withWidth:(CGFloat)width indentationLevel:(int)indentationLevel {
    width -= (2 * 8.0f);
    width -= (indentationLevel * 15.0f);
    
    HNEntryBodyRenderer *renderer = [comment renderer];
    CGSize size = [renderer sizeForWidth:width];
    
    return size.height;
}

+ (CGFloat)heightForEntry:(HNEntry *)entry withWidth:(CGFloat)width expanded:(BOOL)expanded indentationLevel:(int)indentationLevel {
    CGFloat height = [self bodyHeightForComment:entry withWidth:width indentationLevel:indentationLevel] + 30.0f;
    if ([self entryShowsPoints:entry]) height += 14.0f;
    if (expanded) height += 44.0f;
    return height;
}

#pragma mark - Drawing

- (void)drawContentView:(CGRect)rect {
    CGRect bounds = [self bounds];
    bounds.origin.x += (indentationLevel * 15.0f);
    
    CGSize offsets = CGSizeMake(8.0f, 4.0f);
    
    NSString *user = [[comment submitter] identifier];
    NSString *date = [comment posted];
    NSString *points = [comment points] == 1 ? @"1 point" : [NSString stringWithFormat:@"%d points", [comment points]];
    NSString *comments = [comment children] == 0 ? @"" : [comment children] == 1 ? @"1 reply" : [NSString stringWithFormat:@"%d replies", [comment children]];
    
    [[UIColor blackColor] set];
    [user drawAtPoint:CGPointMake(bounds.origin.x + offsets.width, offsets.height - 1.0f) withFont:[[self class] userFont]];
    
    [[UIColor lightGrayColor] set];
    CGFloat datewidth = [date sizeWithFont:[[self class] dateFont]].width;
    [date drawAtPoint:CGPointMake(bounds.size.width - datewidth - offsets.width, offsets.height) withFont:[[self class] dateFont]];
    
    if ([[comment body] length] > 0) {
        bodyRect.size.height = [[self class] bodyHeightForComment:comment withWidth:bounds.size.width indentationLevel:indentationLevel];
        bodyRect.size.width = bounds.size.width - bounds.origin.x - offsets.width - offsets.width;
        bodyRect.origin.x = bounds.origin.x + offsets.width;
        bodyRect.origin.y = offsets.height + 19.0f;

        HNEntryBodyRenderer *renderer = [comment renderer];
        [renderer renderInContext:UIGraphicsGetCurrentContext() rect:bodyRect];
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
    
    // draw link highlight
    for (NSValue *rect in highlightedRects) {
        CGRect highlightedRect = [rect CGRectValue];
        
        if (highlightedRect.size.width != 0 && highlightedRect.size.height != 0) {
            [[UIColor colorWithWhite:0.5f alpha:0.5f] set];
            
            CGRect rect = CGRectInset(highlightedRect, -2.0f, -1.5f);
            rect.origin.x += bodyRect.origin.x;
            rect.origin.y += bodyRect.origin.y;
            
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:2.0f];
            [bezierPath fill];
        }
    }
}

#pragma mark - Tap Handlers

- (void)clearHighlightedRects {
    [highlightedRects release];
    highlightedRects = nil;
}

- (void)singleTapped {
    if ([delegate respondsToSelector:@selector(commentTableCellTapped:)]) {
        [delegate commentTableCellTapped:self];
    }
}

- (void)doubleTapped {
    if ([delegate respondsToSelector:@selector(commentTableCellDoubleTapped:)]) {
        [delegate commentTableCellDoubleTapped:self];
    }
}

- (CGPoint)bodyPointForPoint:(CGPoint)point {
    CGPoint bodyPoint;
    bodyPoint.x = point.x - bodyRect.origin.x;
    bodyPoint.y = point.y - bodyRect.origin.y;
    return bodyPoint;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [self bodyPointForPoint:[touch locationInView:self]];
    
    [self clearHighlightedRects];
    [[comment renderer] linkURLAtPoint:point forWidth:bodyRect.size.width rects:&highlightedRects];
    [highlightedRects retain];
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [self bodyPointForPoint:[touch locationInView:self]];
    
    NSURL *url = [[comment renderer] linkURLAtPoint:point forWidth:bodyRect.size.width rects:NULL];
    
    if (url != nil) {
        if ([delegate respondsToSelector:@selector(commentTableCell:selectedURL:)]) {
            [delegate commentTableCell:self selectedURL:url];
        }
        
        [self clearHighlightedRects];
        [self setNeedsDisplay];
    } else {
        if ([touch tapCount] == 1) {
            [self performSelector:@selector(singleTapped) withObject:nil afterDelay:0.35f];
        } else if ([touch tapCount] == 2) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTapped) object:nil];

            [self doubleTapped];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self clearHighlightedRects];
    
    [self setNeedsDisplay];
}

- (void)actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(NSInteger)index {
	if (index == [sheet cancelButtonIndex]) return;
    
    NSURL *url = [NSURL URLWithString:[sheet sheetContext]];
	
    if (index == [sheet firstOtherButtonIndex]) {
        [[UIApplication sharedApplication] openURL:url];
    } else if (index == [sheet firstOtherButtonIndex] + 1) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setURL:url];
        [pasteboard setString:[url absoluteString]];
    }
}

- (void)longPressFromRecognizer:(UILongPressGestureRecognizer *)gesture {
	if ([gesture state] == UIGestureRecognizerStateBegan) {
        CGPoint point = [self bodyPointForPoint:[gesture locationInView:self]];
        
        NSSet *rects;
        NSURL *url = [[comment renderer] linkURLAtPoint:point forWidth:bodyRect.size.width rects:&rects];
        
        if (url != nil && [rects count] > 0) {
            UIActionSheet *action = [[[UIActionSheet alloc]
                initWithTitle:[url absoluteString]
                delegate:self
                cancelButtonTitle:@"Cancel"
                destructiveButtonTitle:nil
                otherButtonTitles:@"Open in Safari", @"Copy Link", nil
            ] autorelease];
        
            [action setSheetContext:[url absoluteString]];
            [action showFromRect:[[rects anyObject] CGRectValue] inView:self animated:YES];
        }
    }
}

- (void)doubleTapFromRecognizer:(UITapGestureRecognizer *)recognizer {
    if ([delegate respondsToSelector:@selector(commentTableCellDoubleTapped:)]) {
        [delegate commentTableCellDoubleTapped:self];
    }
}

@end
