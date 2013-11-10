//
//  DetailsHeaderView.h
//  newsyc
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "BodyTextView.h"

@protocol DetailsHeaderViewDelegate;

@class HNEntry;
@interface DetailsHeaderView : UIView <BodyTextViewDelegate> {
    HNEntry *entry;
    __weak id<DetailsHeaderViewDelegate> delegate;

    UIView *detailsHeaderContainer;
    UIView *containerContainer;
    BodyTextView *bodyTextView;
    
    BOOL highlighted;
    BOOL navigationCancelled;
}

@property (nonatomic, assign) id<DetailsHeaderViewDelegate> delegate;
@property (nonatomic, retain) HNEntry *entry;
@property (nonatomic, assign, getter = isHighlighted) BOOL highlighted;

- (id)initWithEntry:(HNEntry *)entry_ widthWidth:(CGFloat)width;
- (CGFloat)suggestedHeightWithWidth:(CGFloat)width;
+ (CGSize)offsets;

@end

@protocol DetailsHeaderViewDelegate<NSObject>
@optional

- (void)detailsHeaderView:(DetailsHeaderView *)header selectedURL:(NSURL *)url;

@end
