//
//  HNContainer.h
//  newsyc
//
//  Created by Grant Paul on 2/25/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "HNShared.h"
#import "HNObject.h"

#define kHNContainerLoadingStateLoadingMore 0x00010000

@interface HNContainer : HNObject {
    NSArray *entries;
    
    HNMoreToken moreToken;
    HNAPIRequest *moreRequest;
}

@property (nonatomic, retain) NSArray *entries;
@property (nonatomic, copy) HNMoreToken moreToken;

- (void)beginLoadingMore;
- (BOOL)isLoadingMore;
- (void)cancelLoadingMore;

- (void)loadFromDictionary:(NSDictionary *)response;
- (void)loadFromDictionary:(NSDictionary *)response entries:(NSArray **)outEntries;

@end
