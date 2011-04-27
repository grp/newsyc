//
//  HNSubmission.h
//  newsyc
//
//  Created by Grant Paul on 3/30/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"
#import "HNAPISubmission.h"

#define kHNSubmissionSuccessNotification @"kHNSubmissionSuccessNotification"
#define kHNSubmissionFailureNotification @"kHNSubmissionFailureNotification"

typedef enum {
    kHNSubmissionTypeSubmission,
    kHNSubmissionTypeVote,
    kHNSubmissionTypeFlag,
    kHNSubmissionTypeReply
} HNSubmissionType;

@class HNEntry;
@interface HNSubmission : NSObject <HNAPISubmissionDelegate> {
    HNSubmissionType type;
    HNEntry *target;
    
    NSURL *destination;
    NSString *title;
    NSString *body;
        
    HNVoteDirection direction;
}

@property (nonatomic, readonly) HNSubmissionType type;
@property (nonatomic, retain) HNEntry *target;
@property (nonatomic, copy) NSURL *destination;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) HNVoteDirection direction;

- (HNSubmission *)initWithSubmissionType:(HNSubmissionType)type_;

@end
