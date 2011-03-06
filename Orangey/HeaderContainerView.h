//
//  HeaderContainerView.h
//  Orangey
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class EntryActionsView, DetailsHeaderView, HNEntry;
@interface HeaderContainerView : UIView {
    DetailsHeaderView *detailsHeaderView;
    EntryActionsView *entryActionsView;
    HNEntry *entry;
}

@property (nonatomic, retain) DetailsHeaderView *detailsHeaderView;
@property (nonatomic, retain) EntryActionsView *entryActionsView;
@property (nonatomic, retain) HNEntry *entry;

- (id)initWithEntry:(HNEntry *)entry_ widthWidth:(CGFloat)width;

@end
