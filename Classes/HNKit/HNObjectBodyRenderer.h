//
//  HNObjectBodyRenderer.h
//  newsyc
//
//  Created by Grant Paul on 2/26/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "HNShared.h"

#ifdef HNKIT_RENDERING_ENABLED

#import <CoreText/CoreText.h>

@class HNObject;

@interface HNObjectBodyRenderer : NSObject {
    HNObject *object;
    
    NSAttributedString *attributed;
    CTFramesetterRef framesetter;
}

@property (nonatomic, readonly, assign) HNObject *object;

+ (CGFloat)defaultFontSize;
+ (void)setDefaultFontSize:(CGFloat)size;

- (id)initWithObject:(HNObject *)object;

- (CGSize)sizeForWidth:(CGFloat)width;
- (void)renderInContext:(CGContextRef)context rect:(CGRect)rect;
- (NSURL *)linkURLAtPoint:(CGPoint)point forWidth:(CGFloat)width rects:(NSSet **)rects;

@end

#endif
