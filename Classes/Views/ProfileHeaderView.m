//
//  ProfileHeaderView.m
//  newsyc
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "ProfileHeaderView.h"

@implementation ProfileHeaderView
@synthesize user, padding;

+ (CGFloat)defaultHeight {
    CGFloat height = 65.0;

    if ([UIView instancesRespondToSelector:@selector(tintColor)]) {
        height += 12.0;
    }

    return height;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        titleLabel = [[UILabel alloc] init];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        [titleLabel setTextColor:[UIColor blackColor]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:19.0f]];
        [self addSubview:titleLabel];
        
        subtitleLabel = [[UILabel alloc] init];
        [subtitleLabel setTextAlignment:NSTextAlignmentLeft];
        [subtitleLabel setTextColor:[UIColor darkGrayColor]];
        [subtitleLabel setBackgroundColor:[UIColor clearColor]];
        [subtitleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self addSubview:subtitleLabel];

        if (![UIView instancesRespondToSelector:@selector(tintColor)]) {
            [titleLabel setShadowColor:[UIColor whiteColor]];
            [titleLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];

            [subtitleLabel setShadowColor:[UIColor whiteColor]];
            [subtitleLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        }
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat width = [self bounds].size.width;
    [titleLabel setFrame:CGRectMake(padding, 20.0f, width - (padding * 2), 20.0f)];
    [subtitleLabel setFrame:CGRectMake(padding, 42.0f, width - (padding * 2), 20.0f)];
}

- (void)setPadding:(CGFloat)padding_ {
    padding = padding_;

    [self setNeedsLayout];
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
