//
//  HNEntryList.h
//  Orangey
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HNObject.h"
#import "HNAPIRequest.h"

typedef NSString *HNEntryListType;
#define kHNEntryListTypeNews kHNRequestTypeSubmissions
#define kHNEntryListTypeNew kHNRequestTypeNewSubmissions
#define kHNEntryListTypeAsk kHNRequestTypeAsk
#define kHNEntryListTypeComments kHNRequestTypeNewComments
#define kHNEntryListTypeUserComments kHNRequestTypeCommentsByUser
#define kHNEntryListTypeUserSubmissions kHNRequestTypeSubmissionsByUser
#define kHNEntryListTypeBest @"NOT_YET_SUPPORTED"
#define kHNEntryListTypeClassic @"NOT_YET_SUPPORTED"

@class HNUser;
@interface HNEntryList : HNObject {
    NSMutableArray *entries;
    NSString *nextid;
    HNUser *user;
}

@property (nonatomic, readonly) NSMutableArray *entries;
@property (nonatomic, retain) HNUser *user;

@end
