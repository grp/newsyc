//
//  HNAPISubmission.h
//  newsyc
//
//  Created by Grant Paul on 3/30/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

@protocol HNAPISubmissionDelegate;

typedef enum {
    kHNAPISubmissionLoadingStateReady,
    kHNAPISubmissionLoadingStateFormTokens,
    kHNAPISubmissionLoadingStateFormSubmit
} HNAPISubmissionLoadingState;

@class HNSubmission;
@interface HNAPISubmission : NSObject {
    HNSubmission *submission;
    
    HNAPISubmissionLoadingState loadingState;
    NSMutableData *received;
    NSURLConnection *connection;
}

@property (nonatomic, readonly, retain) HNSubmission *submission;

- (id)initWithSubmission:(HNSubmission *)submission_;
- (void)performSubmission;
- (BOOL)isLoading;

@end

@protocol HNAPISubmissionDelegate
@optional

- (void)submissionCompletedSuccessfully:(BOOL)successfully withError:(NSError *)error;

@end
