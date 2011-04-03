//
//  HNSubmission.m
//  newsyc
//
//  Created by Grant Paul on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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

@end
