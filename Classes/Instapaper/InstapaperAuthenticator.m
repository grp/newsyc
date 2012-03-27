//
//  InstapaperAuthenticator.m
//  newsyc
//
//  Created by Grant Paul on 4/7/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "InstapaperAuthenticator.h"

#import "UIApplication+ActivityIndicator.h"

@implementation InstapaperAuthenticator
@synthesize delegate;

- (void)dealloc {
    [username release];
    [password release];
    [super dealloc];
}

- (id)initWithUsername:(NSString *)username_ password:(NSString *)password_ {
    if ((self = [super init])) {
        username = [username_ copy];
        password = [password_ copy];
    }
    
    return self;
}

- (void)succeed {
    if ([delegate respondsToSelector:@selector(instapaperAuthenticatorDidSucceed:)])
        [delegate instapaperAuthenticatorDidSucceed:self];
}

- (void)failWithError:(NSError *)error {
    if ([delegate respondsToSelector:@selector(instapaperAuthenticator:didFailWithError:)])
        [delegate instapaperAuthenticator:self didFailWithError:error];
}

- (void)failWithErrorText:(NSString *)text {
    NSError *error = [NSError errorWithDomain:@"instapaper" code:0 userInfo:[NSDictionary dictionaryWithObject:text forKey:NSLocalizedDescriptionKey]];
    
    [self failWithError:error];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[UIApplication sharedApplication] releaseNetworkActivityIndicator];
    
    [self failWithError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [[UIApplication sharedApplication] releaseNetworkActivityIndicator];
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        int status = [(NSHTTPURLResponse *) response statusCode];
        if (status == 403) [self failWithErrorText:@"Invalid username or password."];
        if (status == 500) [self failWithErrorText:@"Internal error, try again later."];
        if (status == 201 || status == 200) [self succeed];
    } else {
        [self failWithErrorText:@"Unknown error."];
    }
}

- (void)beginAuthentication {
    NSString *query = @"";
    query = [query stringByAppendingFormat:@"username=%@&", [username stringByURLEncodingString]];
    if (password != nil && [password length] > 0) query = [query stringByAppendingFormat:@"password=%@&", [password stringByURLEncodingString]];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:kInstapaperAPIAuthenticationURL] autorelease];
    NSData *data = [query dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%u", [data length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField: @"Content-Type"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    [connection autorelease];
    
    [[UIApplication sharedApplication] retainNetworkActivityIndicator];
}

@end
