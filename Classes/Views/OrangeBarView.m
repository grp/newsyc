//
//  OrangeBarView.m
//  newsyc
//
//  Created by Grant Paul on 9/28/13.
//
//

#import "OrangeBarView.h"
#import "UIColor+Orange.h"

@implementation OrangeBarView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setUserInteractionEnabled:NO];
        [self setAlpha:0.3];
        [self setBackgroundColor:[UIColor mainOrangeColor]];
    }

    return self;
}

- (void)layoutInsideBar:(UIView *)barView {
    // Hack to deepen the bar's color.
    self.frame = [[[[barView layer] sublayers] objectAtIndex:0] frame];
    [[barView layer] insertSublayer:[self layer] atIndex:1];
}

@end
