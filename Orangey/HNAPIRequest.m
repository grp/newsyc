//
//  HNAPIRequest.m
//  Orangey
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNKit.h"
#import "HNAPIRequest.h"

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
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection_ {
    id result = [[[[SBJsonParser alloc] init] autorelease] objectWithData:received];
    
    [target performSelector:action withObject:self withObject:result withObject:nil];
    [connection release];
}

- (void)performRequestOfType:(NSString *)type withParameters:(NSArray *)parameters {
    received = [[NSMutableData alloc] init];
    
    NSString *base = [@"http://api.ihackernews.com/" stringByAppendingString:type];
    for (NSString *parameter in parameters) {
        base = [base stringByAppendingFormat:@"/%@", parameter];
    }
    
    NSURL *url = [NSURL URLWithString:base];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

- (void)performRequestOfType:(NSString *)type withParameter:(NSString *)parameter {
    [self performRequestOfType:type withParameters:(parameter != nil ? [NSArray arrayWithObject:parameter] : nil)];
}

- (void)performRequestOfType:(NSString *)type withParameter:(NSString *)parameter1 withParameter:(NSString *)parameter2 {
    NSMutableArray *parameters = [NSMutableArray array];
    if (parameter1) [parameters addObject:parameter1];
    if (parameter2) [parameters addObject:parameter2];
    [self performRequestOfType:type withParameters:parameters];
}

- (void)performRequestOfType:(NSString *)type {
    [self performRequestOfType:type withParameter:nil];
}

- (void)cancelRequest {
    if (connection != nil) {
        [connection cancel];
        [connection release];
        connection = nil;
    }
}

@end
