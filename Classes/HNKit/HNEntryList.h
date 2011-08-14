//
//  HNEntryList.h
//  newsyc
//
//  Created by Grant Paul on 8/12/11.
//  Copyright (c) 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"

typedef NSString *HNEntryListIdentifier;

#define kHNEntryListIdentifierSubmissions @"news"
#define kHNEntryListIdentifierNewSubmissions @"newest"
#define kHNEntryListIdentifierBestSubmissions @"best"
#define kHNEntryListIdentifierActiveSubmissions @"active"
#define kHNEntryListIdentifierClassicSubmissions @"classic"
#define kHNEntryListIdentifierAskSubmissions @"ask"
#define kHNEntryListIdentifierBestComments @"bestcomments"
#define kHNEntryListIdentifierNewComments @"newcomments"
#define kHNEntryListIdentifierUserSubmissions @"submitted"
#define kHNEntryListIdentifierUserComments @"threads"

@interface HNEntryList : HNObject {
    HNUser *user;
    NSArray *entries;
}

@property (nonatomic, retain, readonly) HNUser *user;
@property (nonatomic, copy, readonly) NSArray *entries;

+ (id)entryListWithIdentifier:(HNEntryListIdentifier)identifier_;
+ (id)entryListWithIdentifier:(HNEntryListIdentifier)identifier_ user:(HNUser *)user_;


@end
