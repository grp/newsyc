//
//  LoadingController.h
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"
#import "ActivityIndicatorItem.h"
#import "PlacardButton.h"

@class LoadingIndicatorView;
@interface LoadingController : UIViewController <UIActionSheetDelegate, HNObjectLoadingDelegate> {
    HNObject *source;
    
    UIView *statusView;
    PlacardButton *retryButton;
    LoadingIndicatorView *indicator;
    
    UIBarButtonItem *actionItem;
    ActivityIndicatorItem *loadingItem;
}

@property (nonatomic, retain) HNObject *source;

- (id)initWithSource:(HNObject *)source_;
- (void)finishedLoading;

- (void)addStatusView:(UIView *)view;
- (void)addStatusView:(UIView *)view resize:(BOOL)resize;
- (void)removeStatusView:(UIView *)view;

- (void)showError;
- (void)removeError;

@end
