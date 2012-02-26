//
//  HNEntryList.h
//  newsyc
//
//  Created by Grant Paul on 8/12/11.
//  Copyright (c) 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNShared.h"
#import "HNContainer.h"
#import "HNUser.h"

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
#define kHNEntryListIdentifierSaved @"saved"

@interface HNEntryList : HNContainer {
    HNUser *user;
}

@property (nonatomic, retain, readonly) HNUser *user;

+ (id)entryListWithIdentifier:(HNEntryListIdentifier)identifier_;
+ (id)entryListWithIdentifier:(HNEntryListIdentifier)identifier_ user:(HNUser *)user_;

@end
