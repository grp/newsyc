//
//  InstapaperController.h
//  newsyc
//
//  Created by Grant Paul on 2/24/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

@class BarButtonItem;

@interface SharingController : NSObject {
    NSURL *url;
    NSString *title;
    UIViewController *controller;
}

- (id)initWithURL:(NSURL *)url title:(NSString *)title fromController:(UIViewController *)controller;

- (void)showFromView:(UIView *)view;
- (void)showFromView:(UIView *)view atRect:(CGRect)rect;
- (void)showFromBarButtonItem:(BarButtonItem *)item;

@end
