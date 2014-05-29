//
//  LoadingIndicatorView.h
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

@interface LoadingIndicatorView : UIView {
    UIActivityIndicatorView *spinner_;
    UILabel *label_;
    UIView *container_;
}

@property (weak, readonly, nonatomic) UILabel *label;
@property (weak, readonly, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end
