//
//  HNObject.h
//  Orangey
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class HNAPIRequest;
@interface HNObject : NSObject {
    id identifier;
    NSURL *url;
    BOOL loaded;
    
    id target;
    SEL action;
    
    HNAPIRequest *apiRequest;
}

@property (nonatomic, assign) BOOL loaded;
@property (nonatomic, copy) id identifier;
@property (nonatomic, copy) NSURL *URL;

- (id)initWithIdentifier:(id)identifier_ URL:(NSURL *)url_;
- (id)initWithIdentifier:(id)identifier_;
- (id)initWithURL:(NSURL *)url_;

// Overridden in subclasses.
+ (id)_parseParameters:(NSDictionary *)parameters;
+ (id)parseURL:(NSURL *)url_;
+ (NSURL *)generateURL:(id)identifier_;

- (void)beginLoadingWithTarget:(id)target_ action:(SEL)action_;
- (void)beginLoading;

- (void)cancelLoading;

- (void)didFinishLoadingWithError:(NSError *)error;
- (void)didFinishLoading;

@end
