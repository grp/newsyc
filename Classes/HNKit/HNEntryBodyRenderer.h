//
//  EntryBodyRenderer.h
//  newsyc
//
//  Created by Grant Paul on 2/26/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "HNShared.h"

#ifdef HNKIT_RENDERING_ENABLED

#import <CoreText/CoreText.h>

@class HNEntry;

@interface HNEntryBodyRenderer : NSObject {
    HNEntry *entry;
    
    NSAttributedString *attributed;
    CTFramesetterRef framesetter;
}

@property (nonatomic, readonly, assign) HNEntry *entry;

+ (CGFloat)defaultFontSize;
+ (void)setDefaultFontSize:(CGFloat)size;

- (id)initWithEntry:(HNEntry *)entry;

- (CGSize)sizeForWidth:(CGFloat)width;
- (void)renderInContext:(CGContextRef)context rect:(CGRect)rect;
- (NSURL *)linkURLAtPoint:(CGPoint)point forWidth:(CGFloat)width rects:(NSSet **)rects;

@end

#endif
