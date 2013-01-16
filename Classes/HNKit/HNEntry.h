//
//  HNEntry.h
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNShared.h"
#import "HNContainer.h"

#ifdef HNKIT_RENDERING_ENABLED
@class HNObjectBodyRenderer;
#endif

@class HNUser;
@interface HNEntry : HNContainer {
    NSInteger points;
    NSInteger children;
    HNUser *submitter;
    NSString *body;
    NSString *posted;
    HNEntry *parent;
    HNEntry *submission;
    NSURL *destination;
    NSString *title;
#ifdef HNKIT_RENDERING_ENABLED
    HNObjectBodyRenderer *renderer;
#endif
}

@property (nonatomic, assign) NSInteger points;
@property (nonatomic, assign) NSInteger children;
@property (nonatomic, retain) HNUser *submitter;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, retain) NSString *posted;
@property (nonatomic, retain) HNEntry *parent;
@property (nonatomic, retain) HNEntry *submission;
@property (nonatomic, copy) NSURL *destination;
@property (nonatomic, copy) NSString *title;
#ifdef HNKIT_RENDERING_ENABLED
@property (nonatomic, readonly) HNObjectBodyRenderer *renderer;
#endif

- (BOOL)isComment;
- (BOOL)isSubmission;

+ (id)session:(HNSession *)session entryWithIdentifier:(id)identifier_;

@end
