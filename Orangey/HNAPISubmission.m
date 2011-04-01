//
//  HNAPISubmission.m
//  Orangey
//
//  Created by Grant Paul on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNAPISubmission.h"
#import "XMLDocument.h"
#import "NSDictionary+Parameters.h"

@implementation HNAPISubmission
@synthesize submission;

- (void)dealloc {
    [token release];
    [submission release];
    
    [super dealloc];
}

- (id)initWithTarget:(id)target_ action:(SEL)action_ {
    if ((self = [super init])) {
        target = target_;
        action = action_;
        loadingState = 0;
    }
    
    return self;
}

- (void)_completedSuccessfully:(BOOL)successfully withError:(NSError *)error {
    loadingState = 0;

    if ([target respondsToSelector:action])
        [target performSelector:action withObject:[self autorelease] withObject:[NSNumber numberWithBool:successfully] withObject:error];
}

- (void)_addCookiesToRequest:(NSMutableURLRequest *)request {
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
        kHNWebsiteHost, NSHTTPCookieDomain,
        @"/", NSHTTPCookiePath,
        @"user", NSHTTPCookieName,
        (NSString *) token, NSHTTPCookieValue,
    nil];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[NSArray arrayWithObject:cookie]];
    [request setAllHTTPHeaderFields:headers];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection_ {
    NSString *result = [[[NSString alloc] initWithData:received encoding:NSUTF8StringEncoding] autorelease];
    [received release];
    received = nil;
    [connection release];
    connection = nil;
    
    if (loadingState == 1) {
        loadingState = 2;
        
        XMLDocument *document = [[XMLDocument alloc] initWithHTMLData:[result dataUsingEncoding:NSUTF8StringEncoding]];
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
        [self _addCookiesToRequest:request];
        
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
    } else if (loadingState == 2) {
        // Here we "simulate" the action on the locally cached items.
        // XXX: This should really cause a reload action on this element (and it's parent?)
        
        if ([submission type] == kHNSubmissionTypeVote) {
            if ([submission direction] == kHNVoteDirectionUp) {
                [[submission target] setPoints:[[submission target] points] + 1];
            } else {
                [[submission target] setPoints:[[submission target] points] - 1];
            }
        }
        
        [self _completedSuccessfully:YES withError:nil];
    }
}

- (void)connection:(NSURLConnection *)connection_ didFailWithError:(NSError *)error {
    [received release];
    received = nil;
    
    [self _completedSuccessfully:NO withError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [received appendData:data];
}

- (void)performSubmission:(HNSubmission *)submission_ withToken:(HNSessionToken)token_ {
    received = [[NSMutableData alloc] init];
    
    loadingState = 1;
    submission = [submission_ retain];
    token = [token_ copy];
    
    NSURL *url = nil;
    
    if ([submission type] == kHNSubmissionTypeSubmission) {
        NSString *base = [NSString stringWithFormat:@"http://%@/%@", kHNWebsiteHost, @"submit"];
        url = [NSURL URLWithString:base];
    } else {
        url = [[submission target] URL];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self _addCookiesToRequest:request];
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

- (BOOL)isLoading {
    return loadingState > 0;
}

@end
