//
//  LoadMoreView.h
//  newsyc
//
//  Created by Grant Paul on 9/5/11.
//  Copyright (c) 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "LoadingIndicatorView.h"

@interface LoadMoreButton : UIButton {
    LoadingIndicatorView *indicatorView;
    UILabel *moreLabel;
}

- (void)startLoading;
- (void)stopLoading;

@end
