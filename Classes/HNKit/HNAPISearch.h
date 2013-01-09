//
//  HNAPISearch.h
//  newsyc
//
//  Created by Quin Hoxie on 6/2/11.
//

#import "HNKit.h"

#import "NSString+URLEncoding.h"

@interface HNAPISearch : NSObject {
    HNSession *session;
    
	NSMutableData *responseData;
	NSMutableArray *entries;
	HNSearchType searchType;
}

@property (nonatomic, retain, readonly) HNSession *session;
@property (nonatomic, retain) NSMutableArray *entries;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, assign) HNSearchType searchType;

- (id)initWithSession:(HNSession *)session_;

- (void)handleResponse;
- (NSDictionary *)itemFromRaw:(NSDictionary *)rawDictionary;
- (void)performSearch:(NSString *)searchQuery;

@end
