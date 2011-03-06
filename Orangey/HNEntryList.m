//
//  HNEntryList.m
//  Orangey
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNKit.h"
#import "HNEntryList.h"

@implementation HNEntryList
@synthesize entries, user;

+ (id)_parseURL:(NSURL *)url_ {
    NSString *path = [url_ path];
    HNEntryListType type = nil;
    if ([path isEqualToString:@""] || [path isEqualToString:@"news"]) type = kHNEntryListTypeNews;
    if ([path isEqualToString:@"newest"]) type = kHNEntryListTypeNew;
    if ([path isEqualToString:@"ask"]) type = kHNEntryListTypeAsk;
    if ([path isEqualToString:@"newcomments"]) type = kHNEntryListTypeComments;
    if ([path isEqualToString:@"threads"]) type = kHNEntryListTypeUserComments; // XXX: extract user
    if ([path isEqualToString:@"best"]) type = kHNEntryListTypeBest;
    if ([path isEqualToString:@"classic"]) type = kHNEntryListTypeClassic;
    return type;
}

+ (NSURL *)generateURL:(id)identifier_ {
    NSString *path = nil;
    if ([identifier_ isEqual:kHNEntryListTypeNews]) path = @"news";
    if ([identifier_ isEqual:kHNEntryListTypeNew]) path = @"newest";
    if ([identifier_ isEqual:kHNEntryListTypeAsk]) path = @"ask";
    if ([identifier_ isEqual:kHNEntryListTypeComments]) path = @"newcomments";
    if ([identifier_ isEqual:kHNEntryListTypeUserComments]) path = @"threads"; // XXX: include user
    if ([identifier_ isEqual:kHNEntryListTypeBest]) path = @"best";
    if ([identifier_ isEqual:kHNEntryListTypeClassic]) path = @"classic";
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/", kHNWebsiteHost, path]];
}

- (NSString *)description {
    NSString *other = nil;
    if (loaded) other = [NSString stringWithFormat:@"count=%d", [entries count]];
    else other = @"not loaded";
    return [NSString stringWithFormat:@"<%@:%p type=%@ %@>", [self class], self, identifier, other];
}

- (HNEntryList *)initWithIdentifier:(id)identifier_ URL:(NSURL *)url_ {
    if ((self = [super initWithIdentifier:identifier_ URL:url_])) {
        entries = [[NSMutableArray alloc] initWithCapacity:30];
    }
    
    return self;
}

- (void)dealloc {
    [nextid release];
    [entries release];
    
    [super dealloc];
}

- (void)request:(HNAPIRequest *)request completedWithResponse:(NSDictionary *)response error:(NSError *)error {
    if (error == nil && [response isKindOfClass:[NSDictionary class]]) {
        [nextid autorelease];
        nextid = [[response objectForKey:@"nextId"] retain];
        
        NSArray *items = [response objectForKey:@"items"];
        for (NSDictionary *item in items) {
            HNEntry *entry = [[HNEntry alloc] initWithIdentifier:[NSNumber numberWithInt:[[item objectForKey:@"id"] intValue]]];
            [entry loadFromDictionary:item];
            [entries addObject:[entry autorelease]];
        }
    }
    
    [apiRequest autorelease];
    apiRequest = nil;
    [self didFinishLoadingWithError:error];
}

- (void)_load {
    apiRequest= [[HNAPIRequest alloc] initWithTarget:self action:@selector(request:completedWithResponse:error:)];
    NSMutableArray *parameters = [NSMutableArray array];
    if (user != nil) [parameters addObject:[user identifier]];
    if (nextid != nil) [parameters addObject:nextid];
    [apiRequest performRequestOfType:identifier withParameters:parameters];
}

@end
