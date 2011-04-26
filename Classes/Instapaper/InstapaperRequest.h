//
//  InstapaperRequest.h
//  newsyc
//
//  Created by Grant Paul on 4/7/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "InstapaperAPI.h"

@protocol InstapaperRequestDelegate;
@class InstapaperSession;
@interface InstapaperRequest : NSObject {
    InstapaperSession *session;
    id<InstapaperRequestDelegate> delegate;
}

@property (nonatomic, assign) id<InstapaperRequestDelegate> delegate;
@property (nonatomic, readonly) InstapaperSession *session;

- (void)addItemWithURL:(NSURL *)url title:(NSString *)title selection:(NSString *)selection;
- (void)addItemWithURL:(NSURL *)url title:(NSString *)title;
- (void)addItemWithURL:(NSURL *)url;

- (id)initWithSession:(InstapaperSession *)session_;

@end

@protocol InstapaperRequestDelegate <NSObject>
@optional

- (void)instapaperRequestDidAddItem:(InstapaperRequest *)request;
- (void)instapaperRequest:(InstapaperRequest *)request didFailToAddItemWithError:(NSError *)error;

@end

