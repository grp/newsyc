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

#import "SharingController.h"

@implementation CommentTableCell
@synthesize comment, indentationLevel, delegate, expanded;

- (id)initWithReuseIdentifier:(NSString *)identifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier])) {
        [contentView setBackgroundColor:[UIColor whiteColor]];
        [self setShowsDivider:NO];
        
        CALayer *layer = [contentView layer];
        [layer setContentsGravity:kCAGravityBottomLeft];
        [layer setNeedsDisplayOnBoundsChange:YES];
        
        toolbarView = [[EntryActionsView alloc] initWithFrame:CGRectZero];
        [toolbarView sizeToFit];
        [toolbarView setClipsToBounds:YES]; // hide shadow
        [toolbarView setStyle:kEntryActionsViewStyleLight];

        CGRect toolbarFrame = [toolbarView frame];
        toolbarFrame.origin.y = [self bounds].size.height;
        toolbarFrame.size.width = [self bounds].size.width;
        [toolbarView setFrame:toolbarFrame];
        [toolbarView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        
        [self addSubview:toolbarView];
        [self setExpanded:NO];

        bodyTextView = [[BodyTextView alloc] init];
        [bodyTextView setDelegate:self];
        [contentView addSubview:bodyTextView];

        doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapFromRecognizer:)];
        [doubleTapRecognizer setNumberOfTapsRequired:2];
        [doubleTapRecognizer setDelaysTouchesBegan:NO];
        [doubleTapRecognizer setDelaysTouchesEnded:NO];
        [contentView addGestureRecognizer:doubleTapRecognizer];

        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFromRecognizer:)];
        [tapRecognizer setNumberOfTapsRequired:1];
        [tapRecognizer setDelegate:self];
        [tapRecognizer setDelaysTouchesBegan:NO];
        [tapRecognizer setDelaysTouchesEnded:NO];
        [tapRecognizer setCancelsTouchesInView:NO];
        [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
        [contentView addGestureRecognizer:tapRecognizer];

        [tapRecognizer setEnabled:YES];
        [doubleTapRecognizer setEnabled:YES];
    }
    
    return self;
}

- (void)dealloc {
    [comment release];
    [toolbarView release];
    [doubleTapRecognizer release];
    [bodyTextView release];
    [tapRecognizer release];

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
    
    [toolbarView setEntry:comment];
    [bodyTextView setRenderer:[comment renderer]];
    
    [self setNeedsDisplay];
}

- (void)setIndentationLevel:(NSInteger)level {
    indentationLevel = level;
    
    [self setNeedsDisplay];
}

#pragma mark - Configuration

+ (UIEdgeInsets)margins {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return UIEdgeInsetsMake(26.0f, 32.0f, 36.0f, 32.0f);
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIEdgeInsetsMake(11.0f, 12.0f, 16.0f, 12.0);
    }
    
    return UIEdgeInsetsZero;
}

+ (CGSize)offsets {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return CGSizeMake(8.0f, 8.0f);
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return CGSizeMake(8.0f, 4.0f);
    }

    return CGSizeZero;
}

+ (CGFloat)indentationDepth {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return 30.0f;
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return 10.0f;
    }
    
    return 0.0f;
}

+ (UIFont *)userFont {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return [UIFont boldSystemFontOfSize:17.0f];
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return [UIFont boldSystemFontOfSize:14.0f];
    }

    return nil;
}

+ (UIFont *)dateFont {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return [UIFont systemFontOfSize:16.0f];
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return [UIFont systemFontOfSize:13.0f];
    }

    return nil;
}

+ (UIFont *)subtleFont {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return [UIFont systemFontOfSize:16.0f];
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return [UIFont systemFontOfSize:13.0f];
    }

    return nil;
}

+ (BOOL)entryShowsPoints:(HNEntry *)entry {
    // Re-enable this for everyone if comment score viewing is re-enabled.
    return [entry submitter] == [[entry session] user];
}

#pragma mark - Height Calculations

+ (CGFloat)bodyHeightForComment:(HNEntry *)comment withWidth:(CGFloat)width indentationLevel:(NSInteger)indentationLevel {
    width -= ([self margins].left + [self margins].right);
    width -= (indentationLevel * [self indentationDepth]);
    
    HNObjectBodyRenderer *renderer = [comment renderer];
    CGSize size = [renderer sizeForWidth:width];
    
    return size.height;
}

+ (CGFloat)heightForEntry:(HNEntry *)entry withWidth:(CGFloat)width expanded:(BOOL)expanded indentationLevel:(NSInteger)indentationLevel {
    UIEdgeInsets margins = [self margins];
    CGSize offsets = [self offsets];

    CGFloat height = margins.top;
    height += [[self userFont] lineHeight];
    height += [self bodyHeightForComment:entry withWidth:width indentationLevel:indentationLevel];
    if ([self entryShowsPoints:entry]) height += offsets.height + [[self subtleFont] lineHeight];
    height += margins.bottom;
    if (expanded) height += 44.0f;
    
    return height;
}

#pragma mark - Drawing

- (CGRect)drawingBounds {
    CGRect bounds = [self bounds];
    bounds.origin.x += (indentationLevel * [[self class] indentationDepth]);
    if (expanded) bounds.size.height -= [toolbarView bounds].size.height;

    return bounds;
}

- (NSString *)userText {
    return [[comment submitter] identifier];
}

- (CGRect)userRect {
    CGRect bounds = [self drawingBounds];
    UIEdgeInsets margins = [[self class] margins];

    CGRect userrect;
    userrect.origin.x = bounds.origin.x + margins.left;
    userrect.origin.y = margins.top;
    userrect.size = [[self userText] sizeWithFont:[[self class] userFont]];

    return userrect;
}

- (NSString *)dateText {
    return [comment posted];
}

- (CGRect)dateRect {
    CGRect bounds = [self drawingBounds];
    UIEdgeInsets margins = [[self class] margins];

    CGRect daterect;
    daterect.size = [[self dateText] sizeWithFont:[[self class] dateFont]];
    daterect.origin = CGPointMake(bounds.size.width - daterect.size.width - margins.right, margins.top);

    return daterect;
}

- (BOOL)bodyVisible {
    return [[comment body] length] > 0;
}

- (CGRect)bodyRect {
    if ([self bodyVisible]) {
        CGRect bounds = [self drawingBounds];
        UIEdgeInsets margins = [[self class] margins];
        CGSize offsets = [[self class] offsets];
        CGRect daterect = [self dateRect];

        CGRect bodyrect;

        bodyrect.size.height = [[self class] bodyHeightForComment:comment withWidth:bounds.size.width indentationLevel:indentationLevel];
        bodyrect.size.width = bounds.size.width - bounds.origin.x - margins.left - margins.left;
        bodyrect.origin.x = bounds.origin.x + margins.left;
        bodyrect.origin.y = margins.top + daterect.size.height + offsets.height;

        return bodyrect;
    } else {
        return CGRectZero;
    }
}

- (BOOL)pointsVisible {
    return [[self class] entryShowsPoints:comment];
}

- (NSString *)pointsText {
    NSString *points = [comment points] == 1 ? @"1 point" : [NSString stringWithFormat:@"%d points", [comment points]];
    return points;
}

- (CGRect)pointsRect {
    if ([self pointsVisible]) {
        CGRect bounds = [self drawingBounds];
        UIEdgeInsets margins = [[self class] margins];
        CGSize offsets = [[self class] offsets];

        CGRect pointsrect;
        
        pointsrect.size.height = [[self pointsText] sizeWithFont:[[self class] subtleFont]].height;
        pointsrect.size.width = (bounds.size.width + bounds.origin.x) / 2 - margins.left - offsets.width;
        pointsrect.origin.x = bounds.origin.x + margins.left;
        pointsrect.origin.y = bounds.size.height - margins.bottom - pointsrect.size.height;

        return pointsrect;
    } else {
        return CGRectZero;
    }
}

- (NSString *)commentsText {
    NSString *comments = [comment children] == 0 ? @"" : [comment children] == 1 ? @"1 reply" : [NSString stringWithFormat:@"%d replies", [comment children]];
    return comments;
}

- (CGRect)commentsRect {
    if ([self pointsVisible]) {
        CGRect bounds = [self drawingBounds];
        UIEdgeInsets margins = [[self class] margins];
        CGSize offsets = [[self class] offsets];

        CGRect commentsrect;
        
        commentsrect.size.height = [[self commentsText] sizeWithFont:[[self class] subtleFont]].height;
        commentsrect.size.width = (bounds.size.width - bounds.origin.x) / 2 - margins.right - offsets.width;
        commentsrect.origin.x = bounds.size.width - (bounds.size.width - bounds.origin.x) / 2 + offsets.width;
        commentsrect.origin.y = bounds.size.height - margins.bottom - commentsrect.size.height;

        return commentsrect;
    } else {
        return CGRectZero;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [bodyTextView setFrame:[self bodyRect]];
    [bodyTextView setHidden:![self bodyVisible]];
}

- (void)drawContentView:(CGRect)rect {
    CGRect bounds = [self drawingBounds];

    [[UIColor blackColor] set];
    [[self userText] drawInRect:[self userRect] withFont:[[self class] userFont]];

    if (userHighlighted) {
        CGRect rect = CGRectInset([self userRect], -4.0f, -4.0f);
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:3.0f];
        [[UIColor colorWithWhite:0.5f alpha:0.5f] set];
        [bezierPath fill];
    }

    [[UIColor lightGrayColor] set];
    [[self dateText] drawInRect:[self dateRect] withFont:[[self class] dateFont]];

    if ([self pointsVisible]) {
        [[UIColor grayColor] set];
        [[self pointsText] drawInRect:[self pointsRect] withFont:[[self class] subtleFont] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
    
        [[UIColor grayColor] set];
        [[self commentsText] drawInRect:[self commentsRect] withFont:[[self class] subtleFont] lineBreakMode:NSLineBreakByTruncatingHead alignment:NSTextAlignmentRight];
    }
    
    CGRect linerect;
    linerect.size.width = bounds.size.width;
    linerect.size.height = (1.0f / [[UIScreen mainScreen] scale]);
    linerect.origin.x = 0;
    linerect.origin.y = bounds.size.height - linerect.size.height;
    
    [[UIColor colorWithWhite:0.85f alpha:1.0f] set];
    UIRectFill(linerect);
}

#pragma mark - Tap Handlers

- (void)bodyTextView:(BodyTextView *)header selectedURL:(NSURL *)url {
    if ([delegate respondsToSelector:@selector(commentTableCell:selectedURL:)]) {
        [delegate commentTableCell:self selectedURL:url];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == tapRecognizer || gestureRecognizer == doubleTapRecognizer) {
        return ![bodyTextView linkHighlighted] && !userHighlighted;
    } else {
        return YES;
    }
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

- (void)clearHighlights {
    if (userHighlighted) {
        userHighlighted = NO;
        
        [tapRecognizer setEnabled:YES];
        [doubleTapRecognizer setEnabled:YES];
    
        [self setNeedsDisplay];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self clearHighlights];

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];

    if (CGRectContainsPoint([self userRect], location)) {
        userHighlighted = YES;

        [self setNeedsDisplay];

        [tapRecognizer setEnabled:NO];
        [doubleTapRecognizer setEnabled:NO];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (userHighlighted) {
        if ([delegate respondsToSelector:@selector(commentTableCellTappedUser:)]) {
            [delegate commentTableCellTappedUser:self];
        }
    }

    [self clearHighlights];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self clearHighlights];
}

- (void)tapFromRecognizer:(UITapGestureRecognizer *)gesture {
    if (![bodyTextView linkHighlighted] && !userHighlighted) {
        CGPoint location = [gesture locationInView:self];

        if (!expanded || location.y < [toolbarView frame].origin.y) {
            [self singleTapped];
        }
    }
}

- (void)doubleTapFromRecognizer:(UITapGestureRecognizer *)gesture {
    if (![bodyTextView linkHighlighted] &&  !userHighlighted) {
        CGPoint location = [gesture locationInView:self];

        if (!expanded || location.y < [toolbarView frame].origin.y) {
            [self doubleTapped];
        }
    }
}

@end
