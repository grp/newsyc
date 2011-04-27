//
//  InstapaperRequest.h
//  newsyc
//
//  Created by Grant Paul on 4/7/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "InstapaperAPI.h"

@class InstapaperSession;
@interface InstapaperRequest : NSObject {
    InstapaperSession *session;
}

@property (nonatomic, readonly) InstapaperSession *session;

- (void)addItemWithURL:(NSURL *)url title:(NSString *)title selection:(NSString *)selection;
- (void)addItemWithURL:(NSURL *)url title:(NSString *)title;
- (void)addItemWithURL:(NSURL *)url;

- (id)initWithSession:(InstapaperSession *)session_;

@end

#define kInstapaperRequestSucceededNotification @"instapaper-request-completed"
#define kInstapaperRequestFailedNotification @"instapaper-request-failed"

