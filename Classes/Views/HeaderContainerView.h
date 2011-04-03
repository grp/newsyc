//
//  HeaderContainerView.h
//  newsyc
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class DetailsHeaderView, HNEntry;
@interface HeaderContainerView : UIView {
    DetailsHeaderView *detailsHeaderView;
    HNEntry *entry;
}

@property (nonatomic, retain) DetailsHeaderView *detailsHeaderView;
@property (nonatomic, retain) HNEntry *entry;

- (id)initWithEntry:(HNEntry *)entry_ widthWidth:(CGFloat)width;

@end
