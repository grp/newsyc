//
//  BarButtonItem.h
//  newsyc
//
//  Created by Grant Paul on 3/24/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

@interface BarButtonItem : UIBarButtonItem {
    UIView *buttonView;
    
    id realTarget;
    SEL realAction;
}

@property (nonatomic, readonly) UIView *buttonView;

@end

@interface UIPopoverController (BarButtonItem)

- (void)presentPopoverFromBarButtonItemInWindow:(BarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;

@end

@interface UIActionSheet (BarButtonItem)

- (void)showFromBarButtonItemInWindow:(BarButtonItem *)item animated:(BOOL)animated;

@end
