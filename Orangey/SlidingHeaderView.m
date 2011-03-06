//
//  SlidingHeaderViewContainer.m
//  Orangey
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SlidingHeaderView.h"

@implementation SlidingHeaderView
@synthesize targetView;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"began %@", targetView);
    UIView *target = [targetView hitTest:[[touches anyObject] locationInView:targetView] withEvent:event];
    NSLog(@"start target: %@", target);
    [target touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UIView *target = [targetView hitTest:[[touches anyObject] locationInView:targetView] withEvent:event];
    NSLog(@"move target: %@", target);
    [target touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UIView *target = [targetView hitTest:[[touches anyObject] locationInView:targetView] withEvent:event];
    NSLog(@"end target: %@", target);
    [target touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    UIView *target = [targetView hitTest:[[touches anyObject] locationInView:targetView] withEvent:event];
    [target touchesCancelled:touches withEvent:event];
}

- (void)dealloc {
    [targetView release];
    
    [super dealloc];
}

@end
