//
//  HNAPIRequest.m
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"
#import "HNAPIRequest.h"

#import "NSDictionary+Parameters.h"

@implementation HNAPIRequest

- (HNAPIRequest *)initWithTarget:(id)target_ action:(SEL)action_ {
    if ((self = [super init])) {
        target = target_;
        action = action_;
    }
    
    return self;
}

- (void)connection:(NSURLConnection *)connection_ didReceiveData:(NSData *)data {
    [received appendData:data];
}

- (void)connection:(NSURLConnection *)connection_ didFailWithError:(NSError *)error {
    [target performSelector:action withObject:self withObject:nil withObject:error];
    [connection release];
    connection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection_ {
    NSString *resp = [[[NSString alloc] initWithData:received encoding:NSUTF8StringEncoding] autorelease];
    SEL selector = NULL;
    
    if ([type isEqual:kHNPageTypeActiveSubmissions] ||
        [type isEqual:kHNPageTypeAskSubmissions] ||
        [type isEqual:kHNPageTypeBestSubmissions] ||
        [type isEqual:kHNPageTypeClassicSubmissions] ||
        [type isEqual:kHNPageTypeSubmissions] ||
        [type isEqual:kHNPageTypeNewSubmissions] ||
        [type isEqual:kHNPageTypeUserSubmissions]) {
        selector = @selector(parseSubmissionsWithString:);
    } else if ([type isEqual:kHNPageTypeBestComments] ||
        [type isEqual:kHNPageTypeNewComments] ||
        [type isEqual:kHNPageTypeUserComments] ||
        [type isEqual:kHNPageTypeItemComments]) {
        selector = @selector(parseCommentTreeWithString:);
    } else if ([type isEqual:kHNPageTypeUserProfile]) {
        selector = @selector(parseUserProfileWithString:);
    }
    
    HNAPIRequestParser *parser = [[HNAPIRequestParser alloc] init];
    NSDictionary *result = nil;
    if (selector != NULL) result = [parser performSelector:selector withObject:resp];
    [parser release];
 
    [received release];
    received = nil;
    
    [target performSelector:action withObject:self withObject:result withObject:nil];
    [connection release];
    connection = nil;
}

- (void)performRequestOfType:(HNPageType)type_ withParameters:(NSDictionary *)parameters {
    type = [type_ copy];
    received = [[NSMutableData alloc] init];
    
    NSString *base = [NSString stringWithFormat:@"http://%@/%@%@", kHNWebsiteHost, type, [parameters queryString]];
    NSURL *url = [NSURL URLWithString:base];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

- (BOOL)isLoading {
    return connection != nil;
}

- (void)cancelRequest {
    if (connection != nil) {
        [connection cancel];
        [connection release];
        connection = nil;
    }
}

- (void)dealloc {
    [connection release];
    [received release];
    [type release];
    
    [super dealloc];
}

@end
