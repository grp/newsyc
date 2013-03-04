//
//  BodyTextView.h
//  newsyc
//
//  Created by Grant Paul on 1/15/13.
//
//

#import <HNKit/HNKit.h>

@protocol BodyTextViewDelegate;

@interface BodyTextView : UIView {
    HNObjectBodyRenderer *renderer;
    __weak id<BodyTextViewDelegate> delegate;

    UILongPressGestureRecognizer *linkLongPressRecognizer;

    UIView *bodyTextRenderView;
    NSSet *highlightedRects;
}

@property (nonatomic, retain) HNObjectBodyRenderer *renderer;
@property (nonatomic, assign) id<BodyTextViewDelegate> delegate;

- (BOOL)linkHighlighted;

- (void)drawContentView:(CGRect)rect;

@end

@protocol BodyTextViewDelegate <NSObject>
@optional

- (void)bodyTextView:(BodyTextView *)header selectedURL:(NSURL *)url;

@end
