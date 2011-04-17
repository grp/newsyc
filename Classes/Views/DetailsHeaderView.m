//
//  DetailsHeaderView.m
//  newsyc
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "DetailsHeaderView.h"
#import "NSAttributedString+HTML.h"
#import "NSString+Entities.h"
#import "DTLinkButton.h"
#import "HNKit.h"

@implementation DetailsHeaderView
@synthesize delegate, entry;

- (id)initWithEntry:(HNEntry *)entry_ widthWidth:(CGFloat)width {
    if ((self = [super init])) {
        CALayer *layer = [self layer];
        [layer setNeedsDisplayOnBoundsChange:YES];
        
        [self addTarget:self action:@selector(viewPressed:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        textView = [[DTAttributedTextView alloc] init];
        [textView setTextDelegate:self];
        [textView setScrollsToTop:NO];
        [textView setScrollEnabled:NO];
        [self addSubview:textView];
        
        [self setEntry:entry_];
        [self setBackgroundColor:[UIColor whiteColor]];
        
        CGRect frame;
        frame.origin = CGPointZero;
        frame.size.width = width;
        frame.size.height = [self suggestedHeightWithWidth:width];
        [self setFrame:frame];
    }
    
    return self;
}

- (BOOL)hasDestination {
    return [entry destination] != nil;
}

- (void)viewPressed:(DetailsHeaderView *)view withEvent:(UIEvent *)event {
    if (![self hasDestination]) return;
    
    if ([delegate respondsToSelector:@selector(detailsHeaderView:selectedURL:)]) {
        [delegate detailsHeaderView:self selectedURL:[entry destination]];
    }
}

- (void)dealloc {
    [entry release];
    [textView release];
    
    [super dealloc];
}

+ (CGSize)offsets {
    return CGSizeMake(8.0f, 4.0f);
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    [self setNeedsDisplay];
}

+ (UIFont *)titleFont {
    return [UIFont boldSystemFontOfSize:16.0f];
}

+ (UIFont *)subtleFont {
    return [UIFont systemFontOfSize:11.0f];
}

- (void)setEntry:(HNEntry *)entry_ {
    [entry release];
    entry = [entry_ retain];
    
    NSString *body = [entry body];
    NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString *attributed = [[NSAttributedString alloc] initWithHTML:data baseURL:kHNWebsiteURL documentAttributes:NULL];
    [textView setAttributedString:[attributed autorelease]];
    
    [self setNeedsDisplay];
}

+ (UIImage *)disclosureImage; {
    return [UIImage imageNamed:@"disclosure.png"];
}

- (CGFloat)suggestedHeightWithWidth:(CGFloat)width {
    CGSize offsets = [[self class] offsets];
    CGFloat body = [[textView contentView] sizeThatFits:CGSizeMake(width - offsets.width, 0)].height;
    CGFloat disclosure = [self hasDestination] ? [[[self class] disclosureImage] size].width + offsets.width : 0.0f;
    CGFloat title = [[entry title] sizeWithFont:[[self class] titleFont] constrainedToSize:CGSizeMake(width - (offsets.width * 2) - disclosure, 400.0f) lineBreakMode:UILineBreakModeWordWrap].height;
    CGFloat bodyArea = [[entry body] length] > 0 ? offsets.height + body - 12.0f : 0;
    CGFloat titleArea = [[entry title] length] > 0 ? offsets.height + title : 0;
    
    return titleArea + bodyArea + 30.0f + offsets.height + (titleArea > 0 && bodyArea > 0 ? 8.0f : 0);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGSize bounds = [self bounds].size;
    CGSize offsets = [[self class] offsets];
    
    if ([self isHighlighted] && [self hasDestination]) {
        [[UIColor colorWithWhite:0.85f alpha:1.0f] set];
        UIRectFill([self bounds]);
    }
    
    NSString *title = [[entry title] stringByDecodingHTMLEntities];
    NSString *date = [entry posted];
    NSString *points = [entry points] == 1 ? @"1 point" : [NSString stringWithFormat:@"%d points", [entry points]];
    NSString *pointdate = [NSString stringWithFormat:@"%@ • %@", points, date];
    NSString *user = [[entry submitter] identifier];
    UIImage *disclosure = [[self class] disclosureImage];
    
    CGRect titlerect;
    if ([[entry title] length] > 0) {
        [[UIColor blackColor] set];
        
        titlerect.size.width = bounds.width - (offsets.width * 3) - [disclosure size].width;
        titlerect.size.height = [[entry title] sizeWithFont:[[self class] titleFont] constrainedToSize:CGSizeMake(titlerect.size.width, 400.0f) lineBreakMode:UILineBreakModeWordWrap].height;
        titlerect.origin.x = offsets.width;
        titlerect.origin.y = offsets.height + 8.0f;
    } else {
        titlerect = CGRectZero;
    }
    [title drawInRect:titlerect withFont:[[self class] titleFont]];
    
    if ([self hasDestination]) {
        CGRect disclosurerect;
        disclosurerect.size = [disclosure size];
        disclosurerect.origin.x = bounds.width - offsets.width - disclosurerect.size.width;
        disclosurerect.origin.y = titlerect.origin.y + (titlerect.size.height / 2) - (disclosurerect.size.height / 2);
        [disclosure drawInRect:disclosurerect];
    }

    if ([[entry body] length] > 0) {
        CGRect bodyrect;
        bodyrect.origin.y = titlerect.origin.y + titlerect.size.height + offsets.height;
        bodyrect.origin.x = offsets.width / 2;
        bodyrect.size.width = bounds.width - offsets.width;
        bodyrect.size.height = [[textView contentView] sizeThatFits:CGSizeMake(bodyrect.size.width, 0)].height;
        [textView setFrame:bodyrect];
    } else {
        [textView setFrame:CGRectZero];
    }
    
    [[UIColor grayColor] set];
    CGRect pointsrect;
    pointsrect.size.width = bounds.width / 2 - (offsets.width * 2);
    pointsrect.size.height = [pointdate sizeWithFont:[[self class] subtleFont]].height;
    pointsrect.origin.x = offsets.width;
    pointsrect.origin.y = bounds.height - offsets.height - 2.0f - pointsrect.size.height;
    [pointdate drawInRect:pointsrect withFont:[[self class] subtleFont] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
    
    [[UIColor darkGrayColor] set];
    CGRect userrect;
    userrect.size.width = bounds.width / 2 - (offsets.width * 2);
    userrect.size.height = [user sizeWithFont:[[self class] subtleFont]].height;
    userrect.origin.x = bounds.width / 2 + offsets.width;
    userrect.origin.y = bounds.height - offsets.height - 2.0f - userrect.size.height;
    [user drawInRect:userrect withFont:[[self class] subtleFont] lineBreakMode:UILineBreakModeHeadTruncation alignment:UITextAlignmentRight];
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
