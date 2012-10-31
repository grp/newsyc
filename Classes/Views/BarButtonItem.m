//
//  BarButtonItem.m
//  newsyc
//
//  Created by Grant Paul on 3/24/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "BarButtonItem.h"

@implementation BarButtonItem
@synthesize buttonView;

- (void)saveRealTarget:(id)target realAction:(SEL)action {
    realAction = action;
    realTarget = target;
}

- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action {
    if ((self = [super initWithBarButtonSystemItem:systemItem target:self action:@selector(itemSelected:event:)])) {
        [self saveRealTarget:target realAction:action];
    }
    
    return self;
}

- (id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action {
    if ((self = [super initWithImage:image style:style target:self action:@selector(itemSelected:event:)])) {
        [self saveRealTarget:target realAction:action];
    }
    
    return self;
}

- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action {
    if ((self = [super initWithTitle:title style:style target:self action:@selector(itemSelected:event:)])) {
        [self saveRealTarget:target realAction:action];
    }
    
    return self;
}

- (id)initWithImage:(UIImage *)image landscapeImagePhone:(UIImage *)landscapeImagePhone style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action {
    if ((self = [super initWithImage:image landscapeImagePhone:landscapeImagePhone style:style target:self action:@selector(itemSelected:event:)])) {
        [self saveRealTarget:target realAction:action];
    }
    
    return self;
}

- (void)itemSelected:(UIBarButtonItem *)item event:(UIEvent *)event {
    buttonView = [[[[event allTouches] anyObject] view] retain];
    
    if ([realTarget respondsToSelector:realAction]) {
        NSMethodSignature *signature = [realTarget methodSignatureForSelector:realAction];
        int args = [signature numberOfArguments] - 2; // remove self, _cmd
        
        if (args == 0) {
            [realTarget performSelector:realAction];
        } else if (args == 1) {
            [realTarget performSelector:realAction withObject:item];
        } else if (args == 2) {
            [realTarget performSelector:realAction withObject:item withObject:event];
        }
    }
}

- (void)dealloc {
    [buttonView release];
    
    [super dealloc];
}

@end

@implementation UIPopoverController (BarButtonItem)

- (void)presentPopoverFromBarButtonItemInWindow:(BarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated {
    UIView *itemView = [item buttonView];
    UIWindow *window = [itemView window];

    UIView *superview = [itemView superview];
    CGRect windowRect = [superview convertRect:[itemView frame] toView:nil];

    [self presentPopoverFromRect:windowRect inView:window permittedArrowDirections:arrowDirections animated:animated];
}

@end


@implementation UIActionSheet (BarButtonItem)

- (void)showFromBarButtonItemInWindow:(BarButtonItem *)item animated:(BOOL)animated {
    UIView *itemView = [item buttonView];
    UIWindow *window = [itemView window];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIView *superview = [itemView superview];
    
        CGRect windowRect = [superview convertRect:[itemView frame] toView:nil];
        
        // Pretend to be wider, so the arrow is always pointing up or down
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            windowRect = CGRectInset(windowRect, -[[UIScreen mainScreen] bounds].size.width, 0);
        } else {
            windowRect = CGRectInset(windowRect, 0, -[[UIScreen mainScreen] bounds].size.height);
        }
    
        [self showFromRect:windowRect inView:window animated:YES];
    } else {
        [self showInView:window];
    }
}

@end
