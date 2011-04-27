//
//  HNSubmission.m
//  newsyc
//
//  Created by Grant Paul on 3/30/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNSubmission.h"

@implementation HNSubmission
@synthesize type, target, destination, title, body, direction;

- (id)initWithSubmissionType:(HNSubmissionType)type_ {
    if ((self = [super init])) {
        type = type_;
    }
        
    return self;
}

- (void)submissionCompletedSuccessfully:(BOOL)successfully withError:(NSError *)error {
    if (successfully) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHNSubmissionSuccessNotification object:self];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHNSubmissionFailureNotification object:self userInfo:[NSDictionary dictionaryWithObject:error forKey:@"error"]];
    }
}

- (void)dealloc {
    [target release];
    [destination release];
    [body release];
    [title release];
    
    [super dealloc];
}

@end
