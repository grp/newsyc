
#import "NSURL+Parameters.h"
#import "NSObject+PerformSelector.h"
#import "NSString+RemoveSuffix.h"


#define HNKIT_RENDERING_ENABLED


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


typedef enum {
    kHNVoteDirectionDown,
    kHNVoteDirectionUp
} HNVoteDirection;


typedef NSString *HNSessionToken;

typedef NSString *HNMoreToken;
