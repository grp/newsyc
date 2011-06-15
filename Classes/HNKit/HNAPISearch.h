//
//  HNAPISearch.h
//  newsyc
//
//  Created by Quin Hoxie on 6/2/11.
//

#import <Foundation/Foundation.h>
#import "HNKit.h"

@interface HNAPISearch : NSObject <UIApplicationDelegate> {
	NSMutableData *responseData;
	NSMutableArray *entries;
	HNSearchType searchType;
}

@property (nonatomic, retain) NSMutableArray *entries;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, assign) HNSearchType searchType;

- (void)handleResponse;
- (NSDictionary *)itemFromRaw:(NSDictionary *)rawDictionary;
- (void)performSearch:(NSString *)searchQuery;

@end
