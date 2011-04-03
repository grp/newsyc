//
//  DetailsHeaderView.h
//  newsyc
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@protocol DetailsHeaderViewDelegate;

@class HNEntry;
@interface DetailsHeaderView : UIControl {
    HNEntry *entry;
    id<DetailsHeaderViewDelegate> delegate;
}

@property (nonatomic, assign) id<DetailsHeaderViewDelegate> delegate;
@property (nonatomic, retain) HNEntry *entry;

- (CGFloat)suggestedHeightWithWidth:(CGFloat)width;
+ (CGSize)offsets;

@end

@protocol DetailsHeaderViewDelegate<NSObject>
@optional

- (void)detailsHeaderView:(DetailsHeaderView *)header selectedURL:(NSURL *)url;

@end
