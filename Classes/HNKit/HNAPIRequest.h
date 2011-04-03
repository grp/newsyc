//
//  HNAPIRequest.h
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@interface HNAPIRequest : NSObject {
    id target;
    SEL action;
    NSMutableData *received;
    NSURLConnection *connection;
    HNPageType type;
}

- (HNAPIRequest *)initWithTarget:(id)target_ action:(SEL)action_;
- (void)performRequestOfType:(HNPageType)type_ withParameters:(NSDictionary *)parameters;
- (void)cancelRequest;
- (BOOL)isLoading;

@end
