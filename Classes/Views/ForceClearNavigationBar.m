//
//  ForceClearNavigationBar.m
//  newsyc
//
//  Created by Grant Paul on 11/9/13.
//
//

#import "ForceClearNavigationBar.h"

@implementation ForceClearNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        // Have to use 0.001 or UINavigationController thinks its hidden.
        [self setAlpha:0.001];
    }

    return self;
}

- (void)setAlpha:(CGFloat)alpha
{
    // Have to use 0.001 or UINavigationController thinks its hidden.
    [super setAlpha:0.001];
}

@end
