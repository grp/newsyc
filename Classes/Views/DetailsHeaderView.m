//
//  DetailsHeaderView.m
//  newsyc
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import <HNKit/HNKit.h>

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

        bodyTextView = [[BodyTextView alloc] init];
        [bodyTextView setRenderer:[entry renderer]];
        [bodyTextView setDelegate:self];
        [self addSubview:bodyTextView];
        
        CGRect frame;
        frame.origin = CGPointZero;
        frame.size.width = width;
        frame.size.height = [self suggestedHeightWithWidth:width];
        [self setFrame:frame];
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
    [bodyTextView release];
    
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

- (NSString *)titleText {
    NSString *title = [[entry title] stringByDecodingHTMLEntities];
    return title;
}

- (CGRect)titleRect {
    CGSize bounds = [self bounds].size;
    UIEdgeInsets margins = [[self class] margins];
    CGSize offsets = [[self class] offsets];

    if ([[entry title] length] > 0) {
        CGRect titlerect;

        titlerect.origin.x = margins.left;
        titlerect.origin.y = margins.top;
        titlerect.size.width = bounds.width - margins.left - margins.right - [[[self class] disclosureImage] size].width - ([self hasDestination] ? offsets.width : 0);
        titlerect.size.height = [[self titleText] sizeWithFont:[[self class] titleFont] constrainedToSize:CGSizeMake(titlerect.size.width, 400.0f) lineBreakMode:NSLineBreakByWordWrapping].height;

        return titlerect;
    } else {
        return CGRectZero;
    }
}

- (CGRect)disclosureRect {
    CGSize bounds = [self bounds].size;
    UIEdgeInsets margins = [[self class] margins];
    CGRect titlerect = [self titleRect];
    
    if ([self hasDestination]) {
        CGRect disclosurerect;
        
        disclosurerect.size = [[[self class] disclosureImage] size];
        disclosurerect.origin.x = bounds.width - margins.right - disclosurerect.size.width;
        disclosurerect.origin.y = CGRectGetMidY(titlerect) - (disclosurerect.size.height / 2);
    
        return disclosurerect;
    } else {
        return CGRectZero;
    }
}

- (NSString *)pointsText {
    NSString *date = [entry posted];
    NSString *points = [entry points] == 1 ? @"1 point" : [NSString stringWithFormat:@"%d points", [entry points]];

    // Re-enable this for everyone if comment score viewing is re-enabled.
    if ([entry submitter] == [[entry session] user] || [entry isSubmission]) {
        return [NSString stringWithFormat:@"%@ • %@", points, date];
    } else {
        return [NSString stringWithFormat:@"%@", date];
    }
}

- (CGRect)pointsRect {
    CGSize bounds = [self bounds].size;
    UIEdgeInsets margins = [[self class] margins];

    CGRect pointsrect;
    
    pointsrect.size.width = (bounds.width - margins.left - margins.right) / 2;
    pointsrect.size.height = [[self pointsText] sizeWithFont:[[self class] subtleFont]].height;
    pointsrect.origin.x = margins.left;
    pointsrect.origin.y = bounds.height - margins.bottom - 2.0f - pointsrect.size.height;

    return pointsrect;
}

- (NSString *)userText {
    return [[entry submitter] identifier];
}

- (CGRect)userRect {
    CGSize bounds = [self bounds].size;
    UIEdgeInsets margins = [[self class] margins];

    CGRect userrect;
    
    userrect.size.width = (bounds.width - margins.left - margins.right) / 2;
    userrect.size.height = [[self userText] sizeWithFont:[[self class] subtleFont]].height;
    userrect.origin.x = bounds.width - margins.right - userrect.size.width;
    userrect.origin.y = bounds.height - margins.bottom - 2.0f - userrect.size.height;

    return userrect;
}

- (BOOL)bodyVisible {
    return [[entry body] length] > 0;
}

- (CGRect)bodyRect {
    if ([self bodyVisible]) {
        CGSize bounds = [self bounds].size;
        UIEdgeInsets margins = [[self class] margins];
        CGSize offsets = [[self class] offsets];
        CGRect titlerect = [self titleRect];

        CGRect bodyRect;
        bodyRect.origin.x = margins.left;
        bodyRect.origin.y = margins.top + titlerect.size.height + (titlerect.size.height != 0 ? offsets.height : 0);
        bodyRect.size.width = bounds.width - margins.left - margins.right;
        bodyRect.size.height = [[entry renderer] sizeForWidth:bodyRect.size.width].height;

        return bodyRect;
    } else {
        return CGRectZero;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [bodyTextView setFrame:[self bodyRect]];
    [bodyTextView setHidden:![self bodyVisible]];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
        
    if ([self isHighlighted] && [self hasDestination]) {
        [[UIColor colorWithWhite:0.85f alpha:1.0f] set];
        UIRectFill([self bounds]);
    }
    
    [[UIColor blackColor] set];
    [[self titleText] drawInRect:[self titleRect] withFont:[[self class] titleFont]];
    
    if ([self hasDestination]) {
        [[[self class] disclosureImage] drawInRect:[self disclosureRect]];
    }

    [[UIColor grayColor] set];
    [[self pointsText] drawInRect:[self pointsRect] withFont:[[self class] subtleFont] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
    
    [[UIColor darkGrayColor] set];
    [[self userText] drawInRect:[self userRect] withFont:[[self class] subtleFont] lineBreakMode:NSLineBreakByTruncatingHead alignment:NSTextAlignmentRight];
}

#pragma mark - Links

- (void)bodyTextView:(BodyTextView *)header selectedURL:(NSURL *)url {
    if ([delegate respondsToSelector:@selector(detailsHeaderView:selectedURL:)]) {
        [delegate detailsHeaderView:self selectedURL:url];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self hasDestination]) {
        [self setHighlighted:YES];
    }
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self hasDestination]) {
        if ([delegate respondsToSelector:@selector(detailsHeaderView:selectedURL:)]) {
            [delegate detailsHeaderView:self selectedURL:[entry destination]];
        }
    }

    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setHighlighted:NO];
        
    [self setNeedsDisplay];
}

@end
