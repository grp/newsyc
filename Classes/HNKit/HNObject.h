//
//  HNObject.h
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

typedef enum {
    kHNObjectLoadingStateNotLoaded = 0,
    kHNObjectLoadingStateUnloaded = 0,
    kHNObjectLoadingStateLoadingInitial = 1 << 0,
    kHNObjectLoadingStateLoadingReload = 1 << 1,
    kHNObjectLoadingStateLoadingOther = 1 << 2,
    kHNObjectLoadingStateLoadingAny = (kHNObjectLoadingStateLoadingInitial | kHNObjectLoadingStateLoadingReload | kHNObjectLoadingStateLoadingOther),
    kHNObjectLoadingStateLoaded = 1 << 15,
} HNObjectLoadingState;

@protocol HNObjectLoadingDelegate;

@class HNAPIRequest;
@interface HNObject : NSObject {
    id identifier;
    NSURL *url;
    
    HNObjectLoadingState loadingState;
    id<HNObjectLoadingDelegate> delegate;
    
    HNAPIRequest *apiRequest;
}

@property (nonatomic, readonly) HNObjectLoadingState loadingState;
@property (nonatomic, copy) id identifier;
@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, assign) id<HNObjectLoadingDelegate> delegate;

+ (BOOL)isValidURL:(NSURL *)url_;
+ (NSDictionary *)infoDictionaryForURL:(NSURL *)url_;
+ (id)identifierForURL:(NSURL *)url_;

+ (NSString *)pathForURLWithIdentifier:(id)identifier_ infoDictionary:(NSDictionary *)info;
+ (NSDictionary *)parametersForURLWithIdentifier:(id)identifier_ infoDictionary:(NSDictionary *)info;
+ (NSURL *)generateURLWithIdentifier:(id)identifier_ infoDictionary:(NSDictionary *)info;

// These methods don't necessarily create a new object if it's already in the
// cache. The cache is keyed on (type, identifier) pairs managed by HNObject.
+ (id)objectWithIdentifier:(id)identifier_ infoDictionary:(NSDictionary *)info URL:(NSURL *)url_;
+ (id)objectWithIdentifier:(id)identifier_ infoDictionary:(NSDictionary *)info;
+ (id)objectWithIdentifier:(id)identifier_;
+ (id)objectWithURL:(NSURL *)url_;

- (NSDictionary *)infoDictionary;
- (void)loadInfoDictionary:(NSDictionary *)info;

- (NSString *)_additionalDescription;
- (NSString *)description;

- (void)finishLoadingWithResponse:(NSDictionary *)response error:(NSError *)error;

- (void)addLoadingState:(HNObjectLoadingState)state_;
- (void)clearLoadingState:(HNObjectLoadingState)state_;

- (BOOL)isLoaded;
- (BOOL)isLoading;

- (void)cancelLoading;
- (void)beginLoading;

@end

@protocol HNObjectLoadingDelegate <NSObject>
@optional

// Fine-grained monitoring of loading state.
- (void)objectChangedLoadingState:(HNObject *)object;

// Notificatinos of loading starting.
- (void)objectStartedLoading:(HNObject *)object;

// Notifications of loading finality.
- (void)objectFinishedLoading:(HNObject *)object;

// Notifications of loading failure.
- (void)object:(HNObject *)object failedToLoadWithError:(NSError *)error;

@end
