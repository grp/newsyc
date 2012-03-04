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
#import "UIApplication+ActivityIndicator.h"

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
    [[UIApplication sharedApplication] releaseNetworkActivityIndicator];
    
    [connection release];
    connection = nil;
    
    [target performSelector:action withObject:self withObject:nil withObject:error];
}

- (void)completeSuccessfullyWithResult:(NSDictionary *)result {
    [target performSelector:action withObject:self withObject:result withObject:nil];
}

- (void)completeUnsuccessfullyWithError:(NSError *)error {
    [target performSelector:action withObject:self withObject:nil withObject:error];
}

- (void)parseInBackground {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *resp = [[[NSString alloc] initWithData:received encoding:NSUTF8StringEncoding] autorelease];
        
    BOOL success = YES;
    HNAPIRequestParser *parser = [[HNAPIRequestParser alloc] init];
    NSDictionary *result = nil;
    
    @try {
        result = [parser parseWithString:resp];
    } @catch (NSException *e) {
        NSLog(@"HNAPIRequest: Exception parsing page at /%@ with reason \"%@\".", path, [e reason]);
        success = NO;
    }
    
    [parser release];
    
    [received release];
    received = nil;
    
    if (success) {
        [self performSelectorOnMainThread:@selector(completeSuccessfullyWithResult:) withObject:result waitUntilDone:YES];
    } else {
        NSError *error = [NSError errorWithDomain:@"error" code:100 userInfo:[NSDictionary dictionaryWithObject:@"Error scraping." forKey:NSLocalizedDescriptionKey]];
        
        [self performSelectorOnMainThread:@selector(completeUnsuccessfullyWithError:) withObject:error waitUntilDone:YES];
    }
    
    [pool release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection_ {
    [[UIApplication sharedApplication] releaseNetworkActivityIndicator];
    
    [connection release];
    connection = nil;

    [self performSelectorInBackground:@selector(parseInBackground) withObject:nil];
}

- (void)performRequestWithPath:(NSString *)path_ parameters:(NSDictionary *)parameters {
    path = [path_ copy];
    received = [[NSMutableData alloc] init];
    
    NSString *base = [NSString stringWithFormat:@"http://%@/%@%@", kHNWebsiteHost, path, [parameters queryString]];
    NSURL *url = [NSURL URLWithString:base];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [[HNSession currentSession] addCookiesToRequest:request];
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    
    [[UIApplication sharedApplication] retainNetworkActivityIndicator];
}

- (BOOL)isLoading {
    return connection != nil;
}

- (void)cancelRequest {
    if (connection != nil) {
        [[UIApplication sharedApplication] releaseNetworkActivityIndicator];
        
        [connection cancel];
        [connection release];
        connection = nil;
    }
}

- (void)dealloc {
    [connection release];
    [received release];
    [path release];
    
    [super dealloc];
}

@end
