//
//  ProfileHeaderView.m
//  newsyc
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "ProfileHeaderView.h"

@implementation ProfileHeaderView
@synthesize user;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        CGFloat width = frame.size.width;
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 20.0f, width - 40.0f, 20.0f)];
        [titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
        [titleLabel setShadowColor:[UIColor whiteColor]];
        [titleLabel setTextAlignment:UITextAlignmentLeft];
        [titleLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        [titleLabel setTextColor:[UIColor blackColor]];//[UIColor colorWithRed:(76.0f/255.0f) green:(86.0f/255.0f) blue:(108.0f/255.0f) alpha:1.0f]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:19.0f]];
        [self addSubview:titleLabel];
        
        subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 42.0f, width - 40.0f, 20.0f)];
        [subtitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        [subtitleLabel setShadowColor:[UIColor whiteColor]];
        [subtitleLabel setTextAlignment:UITextAlignmentLeft];
        [subtitleLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        [subtitleLabel setTextColor:[UIColor darkGrayColor]];//[UIColor colorWithRed:(76.0f/255.0f) green:(86.0f/255.0f) blue:(108.0f/255.0f) alpha:1.0f]];
        [subtitleLabel setBackgroundColor:[UIColor clearColor]];
        [subtitleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self addSubview:subtitleLabel];
    }
    
    return self;
}

- (NSString *)title {
    return [titleLabel text];
}

- (void)setTitle:(NSString *)title {
    [titleLabel setText:title];
}

- (NSString *)subtitle {
    return [subtitleLabel text];
}

- (void)setSubtitle:(NSString *)subtitle {
    [subtitleLabel setText:subtitle];
}

- (void)dealloc {
    [user release];
    [subtitleLabel release];
    [titleLabel release];
    
    [super dealloc];
}

@end
