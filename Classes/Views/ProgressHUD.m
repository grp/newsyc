//
//  ProgressHUD.m
//  newsyc
//
//  Created by Grant Paul on 4/12/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "ProgressHUD.h"

@implementation ProgressHUD
@synthesize label, text, state;

- (void)layoutSubviews {
    CGFloat topPadding = 24.0f;
    CGFloat innerPadding = 8.0f;
    CGFloat bottomPadding = 20.0f;
    CGFloat horizontalPadding = 12.0f;
    CGSize maximumSize = CGSizeMake(240.0f, 320.0f);
    CGSize minimumSize = CGSizeMake(140.0f, 80.0f);
    CGRect bounds = [self bounds];
    
    CGRect spinnerFrame;
    spinnerFrame.size = [spinner bounds].size;
    spinnerFrame.origin.y = topPadding;
    
    CGRect labelFrame;
    CGSize maximumTextSize = maximumSize;
    maximumTextSize.width -= horizontalPadding + horizontalPadding;
    maximumTextSize.height -= topPadding + spinnerFrame.size.height + innerPadding + bottomPadding;
    labelFrame.size = [text sizeWithFont:[label font] constrainedToSize:maximumTextSize lineBreakMode:UILineBreakModeWordWrap];
    labelFrame.origin.y = topPadding + spinnerFrame.size.height + innerPadding;
    labelFrame.origin.x = horizontalPadding;
    
    CGRect overlayFrame;
    
    if (horizontalPadding + labelFrame.size.width + horizontalPadding > minimumSize.width) {
        overlayFrame.size.width = horizontalPadding + labelFrame.size.width + horizontalPadding;
    } else {
        overlayFrame.size.width = minimumSize.width;
        labelFrame.origin.x = floorf((overlayFrame.size.width / 2) - (labelFrame.size.width / 2));
    }
    
    if (topPadding + spinnerFrame.size.height + innerPadding + labelFrame.size.height + bottomPadding > minimumSize.height) {
        overlayFrame.size.height = topPadding + spinnerFrame.size.height + innerPadding + labelFrame.size.height + bottomPadding;
    } else {
        overlayFrame.size.height = minimumSize.height;
    }
    
    [label setFrame:labelFrame];
    spinnerFrame.origin.x = floorf((overlayFrame.size.width / 2) - (spinnerFrame.size.width / 2));
    [spinner setFrame:spinnerFrame];
    
    CGRect imageFrame = spinnerFrame;
    imageFrame.size = [[image image] size];
    imageFrame.origin.x = floorf((overlayFrame.size.width / 2) - (imageFrame.size.width / 2));
    imageFrame.origin.y += (spinnerFrame.size.height - imageFrame.size.height) / 2;
    [image setFrame:imageFrame];
    
    overlayFrame.origin.y = floorf((bounds.size.height / 2) - (overlayFrame.size.height / 2));
    overlayFrame.origin.x = floorf((bounds.size.width / 2) - (overlayFrame.size.width / 2));
    [overlay setFrame:overlayFrame];
}

- (void)updateForOrientation {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            transform = CGAffineTransformMakeRotation(-M_PI / 2);
            break;
        case UIInterfaceOrientationLandscapeRight:
            transform = CGAffineTransformMakeRotation(M_PI / 2);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            transform = CGAffineTransformMakeRotation(M_PI);
            break;
        case UIInterfaceOrientationPortrait:
            transform = CGAffineTransformMakeRotation(0);
            break;
    }
    
    [self setTransform:transform];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self setUserInteractionEnabled:NO];
        
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [spinner setHidesWhenStopped:YES];
        [spinner sizeToFit];
        
        image = [[UIImageView alloc] init];
        
        label = [[UILabel alloc] init];
        [label setFont:[UIFont boldSystemFontOfSize:22.0f]];
        [label setTextColor:[UIColor whiteColor]];
        [label setTextAlignment:UITextAlignmentCenter];
        [label setLineBreakMode:UILineBreakModeWordWrap];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setNumberOfLines:0];
        
        overlay = [[UIView alloc] init];
        [overlay setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
        [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8f]];
        [[overlay layer] setCornerRadius:10.0f];
        
        [overlay addSubview:spinner];
        [overlay addSubview:image];
        [overlay addSubview:label];
        [self addSubview:overlay];
        
        [self setState:kProgressHUDStateLoading];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateForOrientation) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        [self updateForOrientation];
    }
    
    return self;
}

- (void)setState:(ProgressHUDState)state_ {
    [state autorelease];
    state = [state_ copy];
    
    if ([state isEqual:kProgressHUDStateLoading]) {
        [spinner startAnimating];
        [image setImage:nil];
    } else {
        [spinner stopAnimating];
        
        if ([state isEqual:kProgressHUDStateCompleted]) {
            [image setImage:[UIImage imageNamed:@"check.png"]];
        } else if ([state isEqual:kProgressHUDStateError]) {
            [image setImage:[UIImage imageNamed:@"x.png"]];
        } else {
            NSLog(@"ProgressHUD: Invalid or nil state passed.");
        }
    }
    
    [self setNeedsLayout];
}

- (void)setText:(NSString *)text_ {
    [text autorelease];
    text = [text_ copy];
    
    [label setText:text];
    [self setNeedsLayout];
}

- (void)showInWindow:(UIWindow *)window {
    [self setFrame:[window bounds]];
    [window addSubview:self];
}

- (void)_dismissWithAnimation:(NSNumber *)animated {
    if ([animated boolValue]) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25f];
        [overlay setAlpha:0.0f];
        [UIView commitAnimations];
        
        [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.5f];
    } else {
        [self removeFromSuperview];
    }
}

- (void)dismissWithAnimation:(BOOL)animated {
    [self _dismissWithAnimation:[NSNumber numberWithBool:animated]];
}

- (void)dismiss {
    [self dismissWithAnimation:NO];
}

- (void)dismissAfterDelay:(NSTimeInterval)delay animated:(BOOL)animated {
    [self performSelector:@selector(_dismissWithAnimation:) withObject:[NSNumber numberWithBool:animated] afterDelay:delay];
}

- (void)dismissAfterDelay:(NSTimeInterval)delay {
    [self dismissAfterDelay:delay animated:NO];
}

- (void)dealloc {
    [spinner release];
    [label release];
    [overlay release];
    [image release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [super dealloc];
}

@end
