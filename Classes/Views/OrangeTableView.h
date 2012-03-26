//
//  OrangeTableView.h
//  newsyc
//
//  Created by Grant Paul on 3/26/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrangeTableView : UITableView {
    UIView *tableBackgroundView;
    UIView *orangeBackgroundView;
    BOOL orange;
}

@property (nonatomic, assign) BOOL orange;

@end
