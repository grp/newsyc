//
//  HNContainer.h
//  newsyc
//
//  Created by Grant Paul on 2/25/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "HNShared.h"
#import "HNObject.h"

#define kHNContainerLoadingStateLoadingMore (0x1 << 16)

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

- (void)loadContentsDictionary:(NSDictionary *)contents entries:(NSArray **)outEntries;

@end
