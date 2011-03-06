//
//  HNUser.m
//  Orangey
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSURL+Parameters.h"

#import "HNKit.h"
#import "HNUser.h"

@implementation HNUser
@synthesize karma, average, created, about;

+ (id)_parseParameters:(NSDictionary *)parameters {
    return [parameters objectForKey:@"id"];
}

+ (NSURL *)generateURL:(id)identifier_ {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/user?id=%@", kHNWebsiteHost, identifier_]];
}

- (NSString *)description {
    NSString *other = nil;
    if (loaded) other = [NSString stringWithFormat:@"karma=%d average=%f created=%@ about=%@", karma, average, created, about];
    else other = @"not loaded";
    return [NSString stringWithFormat:@"<%@:%p id=%@ %@>", [self class], self, identifier, other];
}

- (void)request:(HNAPIRequest *)request completedWithResponse:(NSDictionary *)response error:(NSError *)error {
    if (error == nil && [response isKindOfClass:[NSDictionary class]]) {
        [self setAbout:[response objectForKey:@"about"]];
        [self setKarma:[[response objectForKey:@"karma"] intValue]];
        [self setAverage:0.0f];
        [self setCreated:[[response objectForKey:@"createdAgo"] stringByRemovingSuffix:@" ago"]];
    }
    
    [apiRequest autorelease];
    apiRequest = nil;
    [self didFinishLoadingWithError:error];
}

- (void)_load {
    apiRequest = [[HNAPIRequest alloc] initWithTarget:self action:@selector(request:completedWithResponse:error:)];
    [apiRequest performRequestOfType:kHNRequestTypeUserProfile withParameter:identifier];
}

@end
