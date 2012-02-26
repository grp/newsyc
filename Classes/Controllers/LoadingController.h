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
#import "LoginController.h"

#import <MessageUI/MFMailComposeViewController.h>

@class LoadingIndicatorView;
@interface LoadingController : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    HNObject *source;
    
    UIView *statusView;
    NSMutableSet *statusViews;
    
    PlacardButton *retryButton;
    LoadingIndicatorView *indicator;
    
    UIBarButtonItem *actionItem;
    int openInSafariIndex;
    int mailLinkIndex;
    int copyLinkIndex;
    int readLaterIndex;
}

@property (nonatomic, retain) HNObject *source;

- (id)initWithSource:(HNObject *)source_;
- (void)finishedLoading;

- (void)addStatusView:(UIView *)view;
- (void)removeStatusView:(UIView *)view;

- (void)showError;
- (void)removeError;

- (void)sourceStartedLoading;
- (void)sourceFinishedLoading;
- (void)sourceFailedLoading;

@end
