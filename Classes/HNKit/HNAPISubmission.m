//
//  HNAPISubmission.m
//  newsyc
//
//  Created by Grant Paul on 3/30/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"
#import "HNAPISubmission.h"

#import "XMLDocument.h"

#import "NSDictionary+Parameters.h"
#import "UIApplication+ActivityIndicator.h"

@implementation HNAPISubmission
@synthesize submission;

- (void)dealloc {
    [submission release];
    
    [super dealloc];
}

- (id)initWithSubmission:(HNSubmission *)submission_ {
    if ((self = [super init])) {
        submission = [submission_ retain];
        loadingState = kHNAPISubmissionLoadingStateReady;
    }
    
    return self;
}

- (void)_completedSuccessfully:(BOOL)successfully withError:(NSError *)error {
    loadingState = kHNAPISubmissionLoadingStateReady;

    if ([submission respondsToSelector:@selector(submissionCompletedSuccessfully:withError:)])
        [submission submissionCompletedSuccessfully:successfully withError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection_ {
    [[UIApplication sharedApplication] releaseNetworkActivityIndicator];
    
    NSString *result = [[[NSString alloc] initWithData:received encoding:NSUTF8StringEncoding] autorelease];
    [received release];
    received = nil;
    [connection release];
    connection = nil;
    
    if (loadingState == kHNAPISubmissionLoadingStateFormTokens) {
        loadingState = kHNAPISubmissionLoadingStateFormSubmit;
        
        XMLDocument *document = [[XMLDocument alloc] initWithHTMLData:[result dataUsingEncoding:NSUTF8StringEncoding]];
        [document autorelease];
        
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
        [[HNSession currentSession] addCookiesToRequest:request];
        
        if ([submission type] == kHNSubmissionTypeSubmission) {
            XMLElement *element = [document firstElementMatchingPath:@"//input[@name='fnid']"];
            
            NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                [element attributeWithName:@"value"], @"fnid",
                [submission title] ?: @"", @"t",
                [[submission destination] absoluteString] ?: @"", @"u",
                [submission body] ?: @"", @"x",
            nil];

            [request setURL:[NSURL URLWithString:@"/r" relativeToURL:kHNWebsiteURL]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[[[query queryString] substringFromIndex:1] dataUsingEncoding:NSUTF8StringEncoding]];
        } else if ([submission type] == kHNSubmissionTypeVote) {
            NSString *dir = [submission direction] == kHNVoteDirectionUp ? @"up" : @"down";
            NSString *query = [NSString stringWithFormat:@"//a[@id='%@_%@']", dir, [[submission target] identifier]];
            XMLElement *element = [document firstElementMatchingPath:query];
            
            if (element == nil) {
                NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:[NSDictionary dictionaryWithObject:@"Voting not allowed." forKey:NSLocalizedDescriptionKey]];
                [self _completedSuccessfully:NO withError:error];
                return;
            } else {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@", kHNWebsiteHost, [element attributeWithName:@"href"]]];
                [request setURL:url];
            }
        } else if ([submission type] == kHNSubmissionTypeReply) {
            XMLElement *element = [document firstElementMatchingPath:@"//input[@name='fnid']"];
            
            if (element == nil) {
                NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:[NSDictionary dictionaryWithObject:@"Replying not allowed." forKey:NSLocalizedDescriptionKey]];
                [self _completedSuccessfully:NO withError:error];
                return;
            } else {
                NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                    [element attributeWithName:@"value"], @"fnid",
                    [submission body], @"text",
                nil];
                
                [request setURL:[NSURL URLWithString:@"/r" relativeToURL:kHNWebsiteURL]];
                [request setHTTPMethod:@"POST"];
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                [request setHTTPBody:[[[query queryString] substringFromIndex:1] dataUsingEncoding:NSUTF8StringEncoding]];
            }
        } else if ([submission type] == kHNSubmissionTypeFlag) {
            XMLElement *element = [document firstElementMatchingPath:@"//a[text()='flag' and starts-with(@href,'/r?fnid=')]"];
            
            if (element == nil) {
                NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:[NSDictionary dictionaryWithObject:@"Flagging not allowed." forKey:NSLocalizedDescriptionKey]];
                [self _completedSuccessfully:NO withError:error];
                return;
            } else {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", kHNWebsiteHost, [element attributeWithName:@"href"]]];
                [request setURL:url];
            }
        }
        
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [connection start];
        
        [[UIApplication sharedApplication] retainNetworkActivityIndicator];
    } else if (loadingState == kHNAPISubmissionLoadingStateFormSubmit) {
        [self _completedSuccessfully:YES withError:nil];
    }
}

- (void)connection:(NSURLConnection *)connection_ didFailWithError:(NSError *)error {
    [[UIApplication sharedApplication] releaseNetworkActivityIndicator];
    
    [received release];
    received = nil;
    
    [self _completedSuccessfully:NO withError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [received appendData:data];
}

- (void)performSubmission {
    received = [[NSMutableData alloc] init];
    
    loadingState = kHNAPISubmissionLoadingStateFormTokens;
    
    NSURL *url = nil;
    
    if ([submission type] == kHNSubmissionTypeSubmission) {
        NSString *base = [NSString stringWithFormat:@"http://%@/%@", kHNWebsiteHost, @"submit"];
        url = [NSURL URLWithString:base];
    } else {
        url = [[submission target] URL];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [[HNSession currentSession] addCookiesToRequest:request];
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    
    [[UIApplication sharedApplication] retainNetworkActivityIndicator];
}

- (BOOL)isLoading {
    return loadingState != kHNAPISubmissionLoadingStateReady;
}

@end
