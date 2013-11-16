//
//  OrangeToolbar.m
//  newsyc
//
//  Created by Grant Paul on 9/28/13.
//
//

#import "UIColor+Orange.h"
#import "OrangeBarView.h"
#import "OrangeToolbar.h"

@implementation OrangeToolbar
@synthesize orange;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        if ([self respondsToSelector:@selector(barTintColor)]) {
            barView = [[OrangeBarView alloc] init];
            [barView setHidden:YES];
        }
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [barView layoutInsideBar:self];
}

- (void)dealloc {
    [barView release];

    [super dealloc];
}

- (void)setOrange:(BOOL)orange_ {
    orange = orange_;

    if (orange) {
        if ([self respondsToSelector:@selector(setBarTintColor:)]) {
            [self setBarTintColor:[OrangeBarView barOrangeColor]];
            [self setTintColor:[UIColor whiteColor]];
        } else {
            [self setTintColor:[UIColor mainOrangeColor]];
        }
    } else {
        if ([self respondsToSelector:@selector(setBarTintColor:)]) {
            [self setBarTintColor:nil];
        }

        [self setTintColor:nil];
    }

    [barView setHidden:!orange];
}

@end
