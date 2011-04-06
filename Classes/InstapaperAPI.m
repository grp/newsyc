//
//  InstapaperAPI.m
//  newsyc
//
//  Created by Grant Paul on 3/10/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "StatusDelegate.h"
#import "InstapaperAPI.h"

@implementation InstapaperAPI
@synthesize username, password, delegate, lastURL;

+ (id)sharedInstance {
    static id shared = nil;
    if (shared == nil) shared = [[self alloc] init];
    return shared;
}

- (BOOL)canAddItems {
    return username != nil && [username length] > 0;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [delegate handleStatusEventWithType:kStatusDelegateTypeError message:[NSString stringWithFormat:@"Instapaper: %@", [error localizedDescription]]];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        int status = [(NSHTTPURLResponse *) response statusCode];
        if (status == 403) [delegate handleStatusEventWithType:kStatusDelegateTypeError message:@"Invalid Instapaper username or password."];
        if (status == 500) [delegate handleStatusEventWithType:kStatusDelegateTypeError message:@"Instapaper encountered an internal error. Please try again later."];
        if (status == 201) [delegate handleStatusEventWithType:kStatusDelegateTypeNotice message:@"Submitted to Instapaper."];
    } else {
        // XXX: wtf?
    }
}

- (void)addItemWithURL:(NSURL *)url title:(NSString *)title selection:(NSString *)selection {
    if (username == nil || [username length] == 0) {
        [delegate handleStatusEventWithType:kStatusDelegateTypeError message:@"You are not signed into Instapaper."];
        return;
    }

    NSString *query = @"";
    query = [query stringByAppendingFormat:@"username=%@&", [username stringByURLEncodingString]];
    if (password != nil && [password length] > 0) query = [query stringByAppendingFormat:@"password=%@&", [password stringByURLEncodingString]];
    if (title != nil && [title length] > 0) query = [query stringByAppendingFormat:@"title=%@&", [title stringByURLEncodingString]];
    if (selection != nil && [selection length] > 0) query = [query stringByAppendingFormat:@"&title=%@&", [selection stringByURLEncodingString]];
    query = [query stringByAppendingFormat:@"url=%@&", [[url absoluteString] stringByURLEncodingString]];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:kInstapaperAPIAddItemURL] autorelease];
    NSData *data = [query dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%u", [data length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField: @"Content-Type"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    [connection autorelease];
}

- (void)addItemWithURL:(NSURL *)url title:(NSString *)title {
    [self addItemWithURL:url title:title selection:nil];
}

- (void)addItemWithURL:(NSURL *)url {
    [self addItemWithURL:url title:nil selection:nil];
}

@end
