//
//  LoadingController.h
//  Orangey
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNKit.h"

@class LoadingIndicatorView;
@interface LoadingController : UIViewController <UIActionSheetDelegate, HNObjectLoadingDelegate> {
    LoadingIndicatorView *indicator;
    UILabel *errorLabel;
    BOOL loaded;
    HNObject *source;
    UIBarButtonItem *actionItem;
}

@property (nonatomic, retain) HNObject *source;

- (id)initWithSource:(HNObject *)source_;
- (void)performInitialLoadIfPossible;
- (void)finishedLoading;
- (void)showErrorWithTitle:(NSString *)title;

@end
