//
//  HNAPISubmission.h
//  newsyc
//
//  Created by Grant Paul on 3/30/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

@protocol HNAPISubmissionDelegate;

@class HNSubmission;
@interface HNAPISubmission : NSObject {
    HNSessionToken token;
    HNSubmission *submission;
    
    int loadingState;
    NSMutableData *received;
    NSURLConnection *connection;
}

@property (nonatomic, readonly, retain) HNSubmission *submission;

- (id)initWithSubmission:(HNSubmission *)submission_;
- (void)performSubmissionWithToken:(HNSessionToken)token_;
- (BOOL)isLoading;

@end

@protocol HNAPISubmissionDelegate
@optional

- (void)submissionCompletedSuccessfully:(BOOL)successfully withError:(NSError *)error;

@end
