//
//  HNAPISubmission.h
//  Orangey
//
//  Created by Grant Paul on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNSubmission.h"

@interface HNAPISubmission : NSObject {
    id target;
    SEL action;
    
    HNSessionToken token;
    HNSubmission *submission;
    
    int loadingState;
    NSMutableData *received;
    NSURLConnection *connection;
}

@property (nonatomic, readonly, retain) HNSubmission *submission;

- (id)initWithTarget:(id)target_ action:(SEL)action_;
- (void)performSubmission:(HNSubmission *)submission_ withToken:(HNSessionToken)token_;
- (BOOL)isLoading;

@end
