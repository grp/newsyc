//
//  HNObject.h
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNShared.h"

typedef enum {
    kHNObjectLoadingStateNotLoaded = 0,
    kHNObjectLoadingStateUnloaded = 0,
    kHNObjectLoadingStateLoadingInitial = 1 << 0,
    kHNObjectLoadingStateLoadingReload = 1 << 1,
    kHNObjectLoadingStateLoadingOther = 1 << 2,
    kHNObjectLoadingStateLoadingAny = (kHNObjectLoadingStateLoadingInitial | kHNObjectLoadingStateLoadingReload | kHNObjectLoadingStateLoadingOther),
    kHNOBjectLoadingStateCustom = 0xFFFF0000, /* mask */
    kHNObjectLoadingStateLoaded = 1 << 15,
} HNObjectLoadingState;

#define kHNObjectStartedLoadingNotification @"HNObjectStartedLoading"
#define kHNObjectFinishedLoadingNotification @"HNObjectFinishedLoading"
#define kHNObjectFailedLoadingNotification @"HNObjectFailedLoading"
#define kHNObjectLoadingStateChangedNotification @"HNObjectLoadingStateChanged"
#define kHNObjectLoadingStateChangedNotificationErrorKey @"HNObjectLoadingStateChangedNotificationError"

@class HNAPIRequest, HNSession;
@interface HNObject : NSObject {
    id identifier;
    NSURL *url;
    
    HNObjectLoadingState loadingState;
    
    HNAPIRequest *apiRequest;
}

@property (nonatomic, readonly) HNObjectLoadingState loadingState;
@property (nonatomic, copy) id identifier;
@property (nonatomic, copy) NSURL *URL;

+ (BOOL)isValidURL:(NSURL *)url_;
+ (NSDictionary *)infoDictionaryForURL:(NSURL *)url_;
+ (id)identifierForURL:(NSURL *)url_;

+ (NSString *)pathForURLWithIdentifier:(id)identifier_ infoDictionary:(NSDictionary *)info;
+ (NSDictionary *)parametersForURLWithIdentifier:(id)identifier_ infoDictionary:(NSDictionary *)info;
+ (NSURL *)generateURLWithIdentifier:(id)identifier_ infoDictionary:(NSDictionary *)info;

// These methods don't necessarily create a new instance if it's already in the
// cache. The cache's keyed on (class, identifier, info) tuples inside HNObject.
+ (id)objectWithIdentifier:(id)identifier_ infoDictionary:(NSDictionary *)info URL:(NSURL *)url_;
+ (id)objectWithIdentifier:(id)identifier_ infoDictionary:(NSDictionary *)info;
+ (id)objectWithIdentifier:(id)identifier_;
+ (id)objectWithURL:(NSURL *)url_;

- (NSDictionary *)infoDictionary;

- (void)finishLoadingWithResponse:(NSDictionary *)response error:(NSError *)error;

- (void)setIsLoaded:(BOOL)loaded;
- (BOOL)isLoaded;

- (BOOL)isLoading;

- (void)cancelLoading;
- (void)beginLoading;

// Subclasses only below:
- (void)beginLoadingWithState:(HNObjectLoadingState)state_;

- (void)loadInfoDictionary:(NSDictionary *)info;

- (void)addLoadingState:(HNObjectLoadingState)state_;
- (void)clearLoadingState:(HNObjectLoadingState)state_;
- (BOOL)hasLoadingState:(HNObjectLoadingState)state_;

@end

