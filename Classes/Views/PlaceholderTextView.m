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
    [placeholderLabel setHidden:(nil != text_ && ![text_ isEqual:@""])];
    [super setText:text_];
}

- (void)setPlaceholder:(NSString *)placeholder_ {
    [placeholder_ autorelease];
    placeholder = [placeholder_ copy];
    
    [placeholderLabel setText:placeholder];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    
    [placeholderLabel setFont:font];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [placeholderLabel release];
    [placeholder release];
    
    [super dealloc];
}

- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    
    [placeholderLabel setFrame:CGRectMake(8.0f, -8.0f, contentSize.width - 16.0f, contentSize.height + 8.0f)];
}

- (void)beganEditing:(NSNotification *)notification {
    if ([notification object] == self) [placeholderLabel setHidden:YES];
}

- (void)finishedEditing:(NSNotification *)notification {
    if ([notification object] == self) if ([[self text] length] == 0) [placeholderLabel setHidden:NO];
}

- (void)textChanged:(NSNotification *)notification {
    if ([notification object] == self) if ([[self text] length] != 0) [placeholderLabel setHidden:YES];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beganEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
        
        placeholderLabel = [[UILabel alloc] init];
        [placeholderLabel setLineBreakMode:UILineBreakModeWordWrap];
        [placeholderLabel setNumberOfLines:0];
        [placeholderLabel setClipsToBounds:NO];
        [placeholderLabel setFont:[self font]];
        [placeholderLabel setBackgroundColor:[UIColor clearColor]];
        [placeholderLabel setTextColor:[UIColor lightGrayColor]];
        [self addSubview:placeholderLabel];
        
        // Force placeholderLabel to resize.
        [self setContentSize:[self contentSize]];
    }
    
    return self;
}

@end
