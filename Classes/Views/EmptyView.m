//
//  EmptyView.m
//  newsyc
//
//  Created by Grant Paul on 9/28/13.
//
//

#import "EmptyView.h"

@implementation EmptyView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        emptyLabel = [[UILabel alloc] initWithFrame:[self bounds]];
        [emptyLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [emptyLabel setBackgroundColor:[UIColor clearColor]];
        [emptyLabel setTextAlignment:NSTextAlignmentCenter];

        if ([emptyLabel respondsToSelector:@selector(tintColor)]) {
            [emptyLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:22.0]];
            [emptyLabel setTextColor:[UIColor lightGrayColor]];
        } else {
            [emptyLabel setFont:[UIFont systemFontOfSize:17.0f]];
            [emptyLabel setTextColor:[UIColor grayColor]];
        }

        [self addSubview:emptyLabel];
    }

    return self;
}

- (void)setText:(NSString *)text {
    emptyLabel.text = text;
}

@end
