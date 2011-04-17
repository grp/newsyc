//
//  HNObject.h
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

typedef enum {
    kHNObjectLoadingStateNotLoaded = 0,
    kHNObjectLoadingStateLoadingInitial = 1 << 0,
    kHNObjectLoadingStateLoadingReload = 1 << 1,
    kHNObjectLoadingStateLoadingOther = 1 << 2,
    kHNObjectLoadingStateLoadingAny = 0x00000007,
    kHNObjectLoadingStateLoaded = 1 << 15,
} HNObjectLoadingState;

#define kHNObjectLoadingStateUnloaded kHNObjectLoadingStateNotLoaded

@protocol HNObjectLoadingDelegate;

@class HNAPIRequest;
@interface HNObject : NSObject {
    id identifier;
    NSURL *url;
    HNObjectLoadingState loadingState;
    
    id<HNObjectLoadingDelegate> delegate;
    
    HNAPIRequest *apiRequest;
    HNPageType type;
}

@property (nonatomic, readonly) HNObjectLoadingState loadingState;
@property (nonatomic, copy) id identifier;
@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, copy) HNPageType type;
@property (nonatomic, assign) id<HNObjectLoadingDelegate> delegate;

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

- (void)finishLoadingWithResponse:(NSDictionary *)response error:(NSError *)error;

- (void)addLoadingState:(HNObjectLoadingState)state_;
- (void)clearLoadingState:(HNObjectLoadingState)state_;

- (BOOL)isLoaded;
- (BOOL)isLoading;

- (void)cancelLoading;
- (void)beginLoading;
- (void)beginReloading;

@end

@protocol HNObjectLoadingDelegate <NSObject>
@optional

// Fine-grained monitoring of loading state.
- (void)objectChangedLoadingState:(HNObject *)object;
// Notifications of loading finality.
- (void)objectFinishedLoading:(HNObject *)object;
// Notifications of loading failure.
- (void)object:(HNObject *)object failedToLoadWithError:(NSError *)error;

@end
