//
//  HNSessionAuthenticator.m
//  Orangey
//
//  Created by Grant Paul on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNKit.h"
#import "HNSessionAuthenticator.h"

#import "NSDictionary+Parameters.h"
#import "XMLDocument.h"

#define kHNWebsiteLoginURL [NSURL URLWithString:[[kHNWebsiteURL absoluteString] stringByAppendingString:@"y"]]

@implementation HNSessionAuthenticator
@synthesize delegate;

- (void)dealloc {
    if (connection != nil) [connection cancel];
    [connection release];
    [username release];
    [password release];
    
    [super dealloc];
}

- (id)initWithUsername:(NSString *)username_ password:(NSString *)password_ {
    if ((self = [super init])) {
        password = [password_ copy];
        username = [username_ copy];
    }
    
    return self;
}

- (void)__failAuthentication {
    if ([delegate respondsToSelector:@selector(sessionAuthenticatorDidRecieveFailure:)]) {
        [delegate sessionAuthenticatorDidRecieveFailure:self];
    }
}

- (void)_failAuthentication {
    [self performSelectorOnMainThread:@selector(__failAuthentication) withObject:nil waitUntilDone:YES];
}

- (void)__completeAuthenticationWithToken:(HNSessionToken)token {
    if ([delegate respondsToSelector:@selector(sessionAuthenticator:didRecieveToken:)]) {
        [delegate sessionAuthenticator:self didRecieveToken:token];
    }
}

- (void)_completeAuthenticationWithToken:(HNSessionToken)token {
    [self performSelectorOnMainThread:@selector(__completeAuthenticationWithToken:) withObject:token waitUntilDone:YES];
}

- (void)_clearConnection {
    [connection release];
    connection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self _failAuthentication];
    [self _clearConnection];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self _failAuthentication];
    [self _clearConnection];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection_ willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    // XXX: is this necessary? can this cause a hang if it never has the right URL?
    if ([[[request URL] absoluteString] hasSuffix:@"/y"]) return request;

    if (response != nil && [response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *http = (NSHTTPURLResponse *) response;
        
        NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[http allHeaderFields] forURL:[http URL]];
        for (NSHTTPCookie *cookie in cookies) {
            if ([[cookie name] isEqual:@"user"]) {
                [self _completeAuthenticationWithToken:(HNSessionToken) [cookie value]];
                
                [connection cancel];
                [self _clearConnection];
                
                return nil;
            }
        }
    }
    
    [self _failAuthentication];
    [connection cancel];
    [self _clearConnection];
    
    return nil;
}

- (NSString *)_generatePageToken {
    NSData *data = [NSData dataWithContentsOfURL:kHNWebsiteURL];
    XMLDocument *document = [[[XMLDocument alloc] initWithHTMLData:data] autorelease];
    if (document == nil) return nil;
    
    // XXX: this xpath is really ugly :(
    XMLElement *element = [document firstElementMatchingPath:@"//table//tr[1]//table//tr//td//span[@class='pagetop']//a[text()='login']"];
    return [[element attributeWithName:@"href"] substringFromIndex:[@"/x?fnid=" length]];
}

- (NSString *)_generateLoginTokenWithPageToken:(NSString *)pageToken {
    if (pageToken == nil) return nil;
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@x?fnid=%@", [kHNWebsiteURL absoluteString], pageToken]]];
    XMLDocument *document = [[[XMLDocument alloc] initWithHTMLData:data] autorelease];
    if (document == nil) return nil;
    
    XMLElement *element = [document firstElementMatchingPath:@"//form//input[@name='fnid']"];
    return [element attributeWithName:@"value"];
}

- (void)_sendAuthenticationRequest:(NSURLRequest *)request {
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

- (void)_performAuthentication {
    NSString *pagefnid = nil;
    NSString *formfnid = nil;
    
    pagefnid = [self _generatePageToken];
    formfnid = [self _generateLoginTokenWithPageToken:pagefnid];
    
    if (pagefnid == nil || formfnid == nil) {
        [self _failAuthentication];
        return;
    }
    
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
        formfnid, @"fnid",
        username, @"u",
        password, @"p",
    nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:kHNWebsiteLoginURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPShouldHandleCookies:NO];
    
    // Take the slice [1:] so avoid the question mark that doesn't make sense in POST requests.
    // XXX: is that an issue with this category in general?
    [request setHTTPBody:[[[query queryString] substringFromIndex:1] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // The NSURLRequest object must be created on the main thread, or else it
    //  will be destroyed when this thread exits (now), which is not what we want.
    [self performSelectorOnMainThread:@selector(_sendAuthenticationRequest:) withObject:request waitUntilDone:YES];
}

- (void)_authenticateWrapper {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self _performAuthentication];
    [pool release];
}

- (void)beginAuthenticationRequest {
    [NSThread detachNewThreadSelector:@selector(_authenticateWrapper) toTarget:self withObject:nil];
}

@end
