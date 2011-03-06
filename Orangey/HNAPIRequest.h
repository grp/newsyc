//
//  HNAPIRequest.h
//  Orangey
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"

typedef NSString *kHNRequestType;
#define kHNRequestTypeSubmissions @"page"
#define kHNRequestTypeSubmissionsByUser @"by"
#define kHNRequestTypeCommentsByUser @"threads"
#define kHNRequestTypeNewSubmissions @"new"
#define kHNRequestTypeNewComments @"newcomments"
#define kHNRequestTypeAsk @"ask"
#define kHNRequestTypePost @"post"
#define kHNRequestTypeUserProfile @"profile"


@interface HNAPIRequest : NSObject {
    id target;
    SEL action;
    NSMutableData *received;
    NSURLConnection *connection;
}

- (HNAPIRequest *)initWithTarget:(id)target_ action:(SEL)action_;

- (void)performRequestOfType:(NSString *)type withParameters:(NSArray *)parameters;
- (void)performRequestOfType:(NSString *)type withParameter:(NSString *)parameter1 withParameter:(NSString *)parameter2;
- (void)performRequestOfType:(NSString *)type withParameter:(NSString *)parameter;
- (void)performRequestOfType:(NSString *)type;

- (void)cancelRequest;

@end
