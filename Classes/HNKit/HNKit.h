//
//  HNKit.h
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

// This is the main header file for the HNKit "framework",
// which has the singular purpose of scraping Hacker News.
//
// HNKit depends on the files in the "XML" directory, as
// well as few files in the "Categories" folder as well.

#import "NSURL+Parameters.h"
#import "NSObject+PerformSelector.h"
#import "NSString+RemoveSuffix.h"

#define kHNWebsiteHost @"news.ycombinator.com"
#define kHNFAQURL [NSURL URLWithString:@"http://ycombinator.com/newsfaq.html"]
#define kHNWebsiteURL [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/", kHNWebsiteHost]]

typedef NSString *HNPageType;

#define kHNPageTypeSubmissions @"news"
#define kHNPageTypeNewSubmissions @"newest"
#define kHNPageTypeBestSubmissions @"best"
#define kHNPageTypeActiveSubmissions @"active"
#define kHNPageTypeClassicSubmissions @"classic"
#define kHNPageTypeAskSubmissions @"ask"

#define kHNPageTypeItemComments @"item"
#define kHNPageTypeBestComments @"bestcomments"
#define kHNPageTypeNewComments @"newcomments"

#define kHNPageTypeUserProfile @"user"
#define kHNPageTypeUserSubmissions @"submitted"
#define kHNPageTypeUserComments @"threads"

typedef enum {
    kHNVoteDirectionDown,
    kHNVoteDirectionUp
} HNVoteDirection;

#import "HNObject.h"
#import "HNUser.h"
#import "HNEntry.h"
#import "HNAPIRequest.h"
#import "HNAPIParser.h"
#import "HNAPIParserUserProfile.h"
#import "HNAPIParserCommentTree.h"
#import "HNAPIParserSubmissionList.h"
#import "HNSession.h"
#import "HNSessionAuthenticator.h"

