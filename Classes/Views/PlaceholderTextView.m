//
//  PlaceholderTextView.m
//  newsyc
//
//  Created by Grant Paul on 4/1/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "PlaceholderTextView.h"

@implementation PlaceholderTextView
@synthesize placeholder;

- (void)setText:(NSString *)text_ {
    [super setText:text_];

    [placeholderLabel setHidden:[[self text] length] != 0];
}

- (void)setPlaceholder:(NSString *)placeholder_ {
    placeholder = [placeholder_ copy];
    
    [placeholderLabel setText:placeholder];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    
    [placeholderLabel setFont:font];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (UIEdgeInsets)effectiveTextInset {
    UIEdgeInsets textContainerInset = UIEdgeInsetsZero;

    if ([self respondsToSelector:@selector(textContainerInset)]) {
        textContainerInset = [self textContainerInset];

        // The default padding added to text views.
        textContainerInset.left += 4.0;
        textContainerInset.right += 4.0;
    } else {
        // The default padding added to text views.
        textContainerInset.top += 8.0;
        textContainerInset.left += 8.0;
        textContainerInset.bottom += 8.0;
        textContainerInset.right += 8.0;
    }

    return textContainerInset;
}

- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];

    [placeholderLabel setFrame:UIEdgeInsetsInsetRect(CGRectMake(0, 0, contentSize.width, contentSize.height), [self effectiveTextInset])];
}

- (void)textChanged:(NSNotification *)notification {
    if ([notification object] == self) {
        [placeholderLabel setHidden:[[self text] length] != 0];
    }
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
        
        placeholderLabel = [[UILabel alloc] init];
        [placeholderLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [placeholderLabel setNumberOfLines:0];
        [placeholderLabel setClipsToBounds:NO];
        [placeholderLabel setFont:[self font]];
        [placeholderLabel setBackgroundColor:[UIColor clearColor]];
        [placeholderLabel setTextColor:[UIColor lightGrayColor]];
        [self insertSubview:placeholderLabel atIndex:0];
        
        // Force placeholderLabel to resize.
        [self setContentSize:[self contentSize]];
    }
    
    return self;
}

@end
