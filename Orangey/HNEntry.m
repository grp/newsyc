//
//  HNEntry.m
//  Orangey
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSURL+Parameters.h"

#import "HNKit.h"
#import "HNEntry.h"

@implementation HNEntry
@synthesize points, children, submitter, body, posted, parent, title, destination, numchildren;

+ (id)_parseParameters:(NSDictionary *)parameters {
    return [NSNumber numberWithInt:[[parameters objectForKey:@"id"] intValue]];
}

+ (NSURL *)generateURL:(id)identifier_ {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/item?id=%@", kHNWebsiteHost, identifier_]];
}

- (void)setBody:(NSString *)body_ {
    [body autorelease];
    body = body_;
    body = [body stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n\n"];
    body = [body stringByReplacingOccurrencesOfString:@"<font >" withString:@""];
    body = [body stringByReplacingOccurrencesOfString:@"</font>" withString:@""];
    body = [body stringByReplacingOccurrencesOfString:@"<i>" withString:@"/"];
    body = [body stringByReplacingOccurrencesOfString:@"</i>" withString:@"/"];
    [body retain];
}

- (NSString *)description {
    NSString *other = nil;
    if (loaded) other = [NSString stringWithFormat:@"%d points by %@", points, submitter];
    else other = @"not loaded";
    return [NSString stringWithFormat:@"<%@:%p id=%@ %@>", [self class], self, identifier, other];
}

- (void)loadFromDictionary:(NSDictionary *)response {
    [self setPoints:[[response objectForKey:@"points"] intValue]];
    
    [self setBody:[response objectForKey:@"text"] ?: [response objectForKey:@"comment"]];
    [self setPosted:[[response objectForKey:@"postedAgo"] stringByRemovingSuffix:@" ago"]];
    [self setSubmitter:[[[HNUser alloc] initWithIdentifier:[response objectForKey:@"postedBy"]] autorelease]];
    [self setTitle:[response objectForKey:@"title"]];
    [self setDestination:[NSURL URLWithString:[response objectForKey:@"url"]]];
    
    if ([response objectForKey:@"parentId"] != nil) {
        HNEntry *parent_ = [[HNEntry alloc] initWithIdentifier:[NSNumber numberWithInt:[[response objectForKey:@"parentId"] intValue]]];
        [self setParent:[parent_ autorelease]];
    }
    
    NSArray *children_ = [response objectForKey:@"children"] ?: [response objectForKey:@"comments"];
    NSMutableArray *comments = [NSMutableArray array];
    for (NSDictionary *child in children_) {
        HNEntry *entry = [[HNEntry alloc] initWithIdentifier:[NSNumber numberWithInt:[[child objectForKey:@"id"] intValue]]];
        [entry loadFromDictionary:child];
        [entry setLoaded:YES];
        [entry setParent:self];
        [comments addObject:[entry autorelease]];
    }
    [self setChildren:comments];
    
    if ([response objectForKey:@"commentCount"] != nil) {
        [self setNumchildren:[[response objectForKey:@"commentCount"] intValue]];
    } else {
        int num = 0;
        for (HNEntry *child in [self children]) num += [child numchildren];
        [self setNumchildren:num + [[self children] count]];
    }
}

- (void)request:(HNAPIRequest *)request completedWithResponse:(NSDictionary *)response error:(NSError *)error {
    if (error == nil && [response isKindOfClass:[NSDictionary class]]) {
        [self loadFromDictionary:response];
    }
    
    [apiRequest autorelease];
    apiRequest = nil;
    [self didFinishLoadingWithError:error];
}

- (void)_load {
    apiRequest = [[HNAPIRequest alloc] initWithTarget:self action:@selector(request:completedWithResponse:error:)];
    [apiRequest performRequestOfType:kHNRequestTypePost withParameter:identifier];
}

@end
