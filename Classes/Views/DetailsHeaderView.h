//
//  DetailsHeaderView.h
//  newsyc
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "DTAttributedTextView.h"

@protocol DetailsHeaderViewDelegate;

@class HNEntry;
@interface DetailsHeaderView : UIControl <DTAttributedTextViewDelegate, UIActionSheetDelegate> {
    HNEntry *entry;
    id<DetailsHeaderViewDelegate> delegate;
    DTAttributedTextView *textView;
    NSURL *savedURL;
}

@property (nonatomic, assign) id<DetailsHeaderViewDelegate> delegate;
@property (nonatomic, retain) HNEntry *entry;

- (id)initWithEntry:(HNEntry *)entry_ widthWidth:(CGFloat)width;
- (CGFloat)suggestedHeightWithWidth:(CGFloat)width;
+ (CGSize)offsets;

@end

@protocol DetailsHeaderViewDelegate<NSObject>
@optional

- (void)detailsHeaderView:(DetailsHeaderView *)header selectedURL:(NSURL *)url;

@end
