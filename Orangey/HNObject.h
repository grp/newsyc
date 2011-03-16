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
    HNPageType type;
}

@property (nonatomic, assign) BOOL loaded;
@property (nonatomic, copy) id identifier;
@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, copy) HNPageType type;

+ (id)_parseParametersWithType:(HNPageType)type_ parameters:(NSDictionary *)parameters;
+ (id)parseURL:(NSURL *)url_;

+ (NSDictionary *)_generateParametersWithType:(HNPageType)type_ identifier:(id)identifier_;
+ (NSURL *)generateURLWithType:(HNPageType)type_ identifier:(id)identifier_;
+ (NSURL *)generateURLWithType:(HNPageType)type_;
            
- (id)initWithType:(HNPageType)type_ identifier:(id)identifier_ URL:(NSURL *)url_;
- (id)initWithType:(HNPageType)type_ identifier:(id)identifier_;
- (id)initWithType:(HNPageType)type_;
- (id)initWithURL:(NSURL *)url_;

- (NSString *)_additionalDescription;
- (NSString *)description;

- (void)beginLoadingWithTarget:(id)target_ action:(SEL)action_;
- (void)beginLoading;

- (void)cancelLoading;

- (void)finishLoadingWithResponse:(NSDictionary *)response;
- (void)didFinishLoadingWithError:(NSError *)error;

@end
