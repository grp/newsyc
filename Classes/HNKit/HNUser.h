//
//  HNUser.h
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HNObject.h"

#ifdef HNKIT_RENDERING_ENABLED
@class HNObjectBodyRenderer;
#endif

@interface HNUser : HNObject {
    NSInteger karma;
    float average;
    NSString *created;
    NSString *about;
#ifdef HNKIT_RENDERING_ENABLED
    HNObjectBodyRenderer *renderer;
#endif
}

@property (nonatomic, assign) NSInteger karma;
@property (nonatomic, assign) float average;
@property (nonatomic, copy) NSString *created;
@property (nonatomic, copy) NSString *about;
#ifdef HNKIT_RENDERING_ENABLED
@property (nonatomic, readonly) HNObjectBodyRenderer *renderer;
#endif

+ (id)session:(HNSession *)session userWithIdentifier:(id)identifier_;

@end
