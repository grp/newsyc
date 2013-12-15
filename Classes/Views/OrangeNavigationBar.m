//
//  OrangeNavigationBar.m
//  newsyc
//
//  Created by Grant Paul on 9/28/13.
//
//

#import "UIColor+Orange.h"
#import "OrangeBarView.h"
#import "OrangeNavigationBar.h"

@implementation OrangeNavigationBar
@synthesize orange;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        if ([self respondsToSelector:@selector(barTintColor)]) {
            barView = [[OrangeBarView alloc] init];
            [barView setHidden:YES];
            
            UITapGestureRecognizer *tripleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                         action:@selector(startTheParty:)];
            tripleTapGestureRecognizer.numberOfTapsRequired = 3;
            [self addGestureRecognizer:tripleTapGestureRecognizer];
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

            NSDictionary *titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
            [self setTitleTextAttributes:titleTextAttributes];
        } else {
            [self setTintColor:[UIColor mainOrangeColor]];
        }
    } else {
        if ([self respondsToSelector:@selector(setBarTintColor:)]) {
            [self setBarTintColor:nil];
        }

        [self setTintColor:nil];
        [self setTitleTextAttributes:nil];
    }

    [barView setHidden:!orange];
}

#pragma mark -
#pragma mark Party Mode

- (void)setPartyTimer:(NSTimer *)partyTimer {
    if (partyTimer == _partyTimer)
        return;
    
    [_partyTimer invalidate];
    _partyTimer = partyTimer;
}

- (void)startTheParty:(UIGestureRecognizer *)sender {
    BOOL isPartying = self.shouldParty;
    self.shouldParty = !isPartying;
}

- (void)setShouldParty:(BOOL)shouldParty {
    _shouldParty = shouldParty;
    
    if (shouldParty) {
        NSTimer *partyTimer = [NSTimer timerWithTimeInterval:1.0 / 30.0
                                                  target:self
                                                selector:@selector(keepThePartyGoing:)
                                                userInfo:nil
                                                 repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:partyTimer forMode:NSRunLoopCommonModes];
        self.partyTimer = partyTimer;
    } else {
        self.partyTimer = nil;
        self.orange = orange;
    }
}

- (void)keepThePartyGoing:(NSTimer *)timer {
    partyHue += 1.0f / 360.0f;
    if (partyHue > 1.0f)
        partyHue = 0.0f;
    
    UIColor *partyColor = [UIColor colorWithHue:partyHue
                                saturation:1.0f
                                brightness:1.0f
                                     alpha:1.0f];
    
    if ([self respondsToSelector:@selector(setBarTintColor:)]) {
        [self setBarTintColor:partyColor];
        [self setTintColor:[UIColor whiteColor]];
        
        NSDictionary *titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        [self setTitleTextAttributes:titleTextAttributes];
    } else {
        [self setTintColor:partyColor ];
    }
}

@end
