
#import "NSURL+Parameters.h"
#import "NSObject+PerformSelector.h"
#import "NSString+RemoveSuffix.h"

#define kHNWebsiteHost @"news.ycombinator.com"
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

#import "HNObject.h"
#import "HNUser.h"
#import "HNEntry.h"
#import "HNAPIRequest.h"
#import "HNAPIParserItem.h"
#import "HNAPIParserItemUserProfile.h"
#import "HNAPIParserItemCommentTree.h"
#import "HNAPIParserItemSubmissionList.h"
