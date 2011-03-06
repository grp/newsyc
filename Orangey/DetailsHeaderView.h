//
//  DetailsHeaderView.h
//  Orangey
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class HNEntry;
@interface DetailsHeaderView : UIControl {
    HNEntry *entry;
    id delegate;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) HNEntry *entry;

+ (CGFloat)heightForEntry:(HNEntry *)entry withWidth:(CGFloat)width;
+ (CGSize)offsets;

@end
