//
//  LoadingController.h
//  Orangey
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoadingIndicatorView;
@class HNObject;

@interface LoadingController : UIViewController {
    LoadingIndicatorView *indicator;
    BOOL loaded;
    HNObject *source;
}

@property (nonatomic, retain) HNObject *source;

- (id)initWithSource:(HNObject *)source_;
- (void)finishedLoading;

@end
