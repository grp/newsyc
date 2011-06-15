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

#define kHNSearchBaseURL @"http://api.thriftdb.com/api.hnsearch.com/items/_search?%@"
#define kHNSearchParamsInteresting @"limit=100&filter[fields][type][]=submission&weights[title]=8&weights[text]=2&weights[domain]=3&weights[username]=3&weights[type]=0&boosts[fields][points]=3&boosts[fields][num_comments]=3&boosts[functions][recip(ms(NOW,create_ts),3.16e-11,1,1)]=2.0&q=%@"
#define kHNSearchParamsRecent @"sortby=create_ts%%20desc&limit=100&filter[fields][type][]=submission&weights[title]=8&weights[text]=2&weights[domain]=3&weights[username]=3&weights[type]=0&boosts[fields][points]=3&boosts[fields][num_comments]=3&boosts[functions][recip(ms(NOW,create_ts),3.16e-11,1,1)]=2.0&q=%@"
typedef enum {
    kHNSearchTypeInteresting,
    kHNSearchTypeRecent
} HNSearchType;


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

typedef NSString *HNSessionToken;

// data
#import "HNObject.h"
#import "HNUser.h"
#import "HNEntry.h"

// sessions
#import "HNSession.h"
#import "HNAnonymousSession.h"
#import "HNSessionAuthenticator.h"
#import "HNSubmission.h"

// internal
#import "HNAPIRequest.h"
#import "HNAPIRequestParser.h"
#import "HNAPISubmission.h"

