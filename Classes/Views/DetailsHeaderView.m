//
//  DetailsHeaderView.m
//  newsyc
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"

#import "DetailsHeaderView.h"

#import "NSString+Entities.h"

#import "SharingController.h"

@implementation DetailsHeaderView
@synthesize delegate, entry, highlighted;

- (id)initWithEntry:(HNEntry *)entry_ widthWidth:(CGFloat)width {
    if ((self = [super init])) {
        CALayer *layer = [self layer];
        [layer setNeedsDisplayOnBoundsChange:YES];
                
        [self setEntry:entry_];
        [self setBackgroundColor:[UIColor whiteColor]];
        
        CGRect frame;
        frame.origin = CGPointZero;
        frame.size.width = width;
        frame.size.height = [self suggestedHeightWithWidth:width];
        [self setFrame:frame];
        
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFromRecognizer:)];
        [longPressRecognizer setMinimumPressDuration:0.65f];
        [self addGestureRecognizer:[longPressRecognizer autorelease]];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self setNeedsDisplay];
}

- (BOOL)hasDestination {
    return [entry destination] != nil;
}

- (void)dealloc {
    [entry release];
    
    [super dealloc];
}

+ (UIEdgeInsets)margins {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return UIEdgeInsetsMake(20.0f, 30.0f, 20.0f, 30.0f);
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIEdgeInsetsMake(10.0f, 8.0f, 4.0f, 8.0f);
    }

    return UIEdgeInsetsZero;
}

+ (CGSize)offsets {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return CGSizeMake(12.0f, 12.0f);
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return CGSizeMake(8.0f, 8.0f);
    }

    return CGSizeZero;
}

+ (UIFont *)titleFont {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return [UIFont boldSystemFontOfSize:19.0f];
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return [UIFont boldSystemFontOfSize:16.0f];
    }

    return nil;
}

+ (UIFont *)bodyFont {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return [UIFont boldSystemFontOfSize:19.0f];
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return [UIFont boldSystemFontOfSize:16.0f];
    }

    return nil;
}

+ (UIFont *)subtleFont {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return [UIFont systemFontOfSize:16.0f];
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return [UIFont systemFontOfSize:12.0f];
    }

    return nil;
}

- (void)setEntry:(HNEntry *)entry_ {
    [entry release];
    entry = [entry_ retain];
    
    [self setNeedsDisplay];
}

+ (UIImage *)disclosureImage; {
    return [UIImage imageNamed:@"disclosure.png"];
}

- (CGFloat)suggestedHeightWithWidth:(CGFloat)width {
    UIEdgeInsets margins = [[self class] margins];
    CGSize offsets = [[self class] offsets];
    
    CGFloat body = [[entry renderer] sizeForWidth:(width - margins.left - margins.right)].height;
    CGFloat disclosure = [self hasDestination] ? [[[self class] disclosureImage] size].width + offsets.width : 0.0f;
    CGFloat title = [[entry title] sizeWithFont:[[self class] titleFont] constrainedToSize:CGSizeMake(width - margins.left - margins.right - disclosure, 400.0f) lineBreakMode:NSLineBreakByWordWrapping].height;
    CGFloat date = [[entry posted] sizeWithFont:[[self class] subtleFont]].height;

    // Don't make space for something we don't have.
    title = ([[entry title] length] > 0 ? title : 0);
    body = ([[entry body] length] > 0 ? body : 0);

    // Add padding between the title and the body if we have both. 
    CGFloat titleBodyPadding = ([[entry body] length] > 0 && [[entry title] length] > 0 ? offsets.height : 0);
    
    return margins.top + title + titleBodyPadding + body + offsets.height + date + margins.bottom;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGSize bounds = [self bounds].size;
    UIEdgeInsets margins = [[self class] margins];
    CGSize offsets = [[self class] offsets];
    
    if ([self isHighlighted] && [self hasDestination]) {
        [[UIColor colorWithWhite:0.85f alpha:1.0f] set];
        UIRectFill([self bounds]);
    }
    
    NSString *title = [[entry title] stringByDecodingHTMLEntities];
    NSString *date = [entry posted];
    NSString *points = [entry points] == 1 ? @"1 point" : [NSString stringWithFormat:@"%d points", [entry points]];
    NSString *pointdate = nil;
    NSString *user = [[entry submitter] identifier];
    UIImage *disclosure = [[self class] disclosureImage];
    
    // Re-enable this for everyone if comment score viewing is re-enabled.
    if ([entry submitter] == [[entry session] user] || [entry isSubmission]) {
        pointdate = [NSString stringWithFormat:@"%@ • %@", points, date];
    } else {
        pointdate = [NSString stringWithFormat:@"%@", date];
    }
    
    CGRect titlerect;
    CGFloat titleafter = 0;
    if ([[entry title] length] > 0) {
        [[UIColor blackColor] set];

        titlerect.origin.x = margins.left;
        titlerect.origin.y = margins.top;
        titlerect.size.width = bounds.width - margins.left - margins.right - [disclosure size].width - ([self hasDestination] ? offsets.width : 0);
        titlerect.size.height = [[entry title] sizeWithFont:[[self class] titleFont] constrainedToSize:CGSizeMake(titlerect.size.width, 400.0f) lineBreakMode:NSLineBreakByWordWrapping].height;
        [title drawInRect:titlerect withFont:[[self class] titleFont]];

        titleafter = offsets.height;
    } else {
        titlerect = CGRectZero;
        titleafter = 0;
    }
    
    if ([self hasDestination]) {
        CGRect disclosurerect;
        disclosurerect.size = [disclosure size];
        disclosurerect.origin.x = bounds.width - margins.right - disclosurerect.size.width;
        disclosurerect.origin.y = CGRectGetMidY(titlerect) - (disclosurerect.size.height / 2);
        [disclosure drawInRect:disclosurerect];
    }

    if ([[entry body] length] > 0) {
        HNEntryBodyRenderer *renderer = [entry renderer];

        bodyRect.origin.x = margins.left;
        bodyRect.origin.y = margins.top + titlerect.size.height + titleafter;
        bodyRect.size.width = bounds.width - margins.left - margins.right;
        bodyRect.size.height = [renderer sizeForWidth:bodyRect.size.width].height;
            
        [renderer renderInContext:UIGraphicsGetCurrentContext() rect:bodyRect];
    }
    
    [[UIColor grayColor] set];
    CGRect pointsrect;
    pointsrect.size.width = (bounds.width - margins.left - margins.right) / 2;
    pointsrect.size.height = [pointdate sizeWithFont:[[self class] subtleFont]].height;
    pointsrect.origin.x = margins.left;
    pointsrect.origin.y = bounds.height - margins.bottom - 2.0f - pointsrect.size.height;
    [pointdate drawInRect:pointsrect withFont:[[self class] subtleFont] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
    
    [[UIColor darkGrayColor] set];
    CGRect userrect;
    userrect.size.width = (bounds.width - margins.left - margins.right) / 2;
    userrect.size.height = [user sizeWithFont:[[self class] subtleFont]].height;
    userrect.origin.x = bounds.width - margins.right - userrect.size.width;
    userrect.origin.y = bounds.height - margins.bottom - 2.0f - userrect.size.height;
    [user drawInRect:userrect withFont:[[self class] subtleFont] lineBreakMode:NSLineBreakByTruncatingHead alignment:NSTextAlignmentRight];
    
    // draw link highlight
    UIBezierPath *highlightBezierPath = [UIBezierPath bezierPath];
    for (NSValue *rect in highlightedRects) {
        CGRect highlightedRect = CGRectIntegral([rect CGRectValue]);

        if (highlightedRect.size.width != 0 && highlightedRect.size.height != 0) {
            CGRect rect = CGRectInset(highlightedRect, -4.0f, -4.0f);
            rect.origin.x += bodyRect.origin.x;
            rect.origin.y += bodyRect.origin.y;

            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:3.0f];
            [highlightBezierPath appendPath:bezierPath];
        }
    }
    [[UIColor colorWithWhite:0.5f alpha:0.5f] set];
    [highlightBezierPath fill];
}

#pragma mark - Links

- (void)clearHighlightedRects {
    [highlightedRects release];
    highlightedRects = nil;
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
    NSURL *url = [[entry renderer] linkURLAtPoint:point forWidth:bodyRect.size.width rects:&highlightedRects];
    [highlightedRects retain];
    
    // if there's not a URL, click the header
    if (url == nil && [self hasDestination]) {
        [self setHighlighted:YES];
    }
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [self bodyPointForPoint:[touch locationInView:self]];
    
    NSURL *url = [[entry renderer] linkURLAtPoint:point forWidth:bodyRect.size.width rects:NULL];
    
    if (url != nil && !navigationCancelled) {
        if ([delegate respondsToSelector:@selector(detailsHeaderView:selectedURL:)]) {
            [delegate detailsHeaderView:self selectedURL:url];
        }
        
        [self clearHighlightedRects];
    } else if ([self hasDestination]) {
        if ([delegate respondsToSelector:@selector(detailsHeaderView:selectedURL:)]) {
            [delegate detailsHeaderView:self selectedURL:[entry destination]];
        }
    }

    navigationCancelled = NO;
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setHighlighted:NO];
    
    navigationCancelled = NO;
    [self clearHighlightedRects];
    
    [self setNeedsDisplay];
}

- (void)longPressFromRecognizer:(UILongPressGestureRecognizer *)gesture {
	if ([gesture state] == UIGestureRecognizerStateBegan) {
        CGPoint location = [gesture locationInView:self];
        CGPoint point = [self bodyPointForPoint:location];
        
        NSSet *rects;
        NSURL *url = [[entry renderer] linkURLAtPoint:point forWidth:bodyRect.size.width rects:&rects];
        
        if (url != nil && [rects count] > 0) {
            SharingController *sharingController = [[SharingController alloc] initWithURL:url title:nil fromController:nil];
            [sharingController showFromView:self atRect:CGRectInset(CGRectMake(location.x, location.y, 0, 0), -4.0f, -4.0f)];
            [sharingController release];

            navigationCancelled = YES;
        }
    }
}

@end
