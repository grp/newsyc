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
@synthesize points, children, submitter, body, posted, parent, title, destination, entries;

+ (BOOL)typeUsesIdentifier:(HNPageType)type_ {
    return ([type_ isEqual:kHNPageTypeUserComments] ||
            [type_ isEqual:kHNPageTypeUserSubmissions] ||
            [type_ isEqual:kHNPageTypeItemComments]);
}

+ (id)_parseParametersWithType:(HNPageType)type_ parameters:(NSDictionary *)parameters {
    if ([self typeUsesIdentifier:type_]) {
        return [NSNumber numberWithInt:[[parameters objectForKey:@"id"] intValue]];
    } else {
        return nil;
    }
}

+ (NSDictionary *)_generateParametersWithType:(HNPageType)type_ identifier:(id)identifier_ {
    if ([self typeUsesIdentifier:type_] && identifier_ != nil) {
        return [NSDictionary dictionaryWithObject:identifier_ forKey:@"id"];
    } else {
        return [NSDictionary dictionary];
    }
}

- (NSString *)_additionalDescription {
    return [NSString stringWithFormat:@"%d points by %@", points, submitter];
}

- (void)loadFromDictionary:(NSDictionary *)response {
    if ([response objectForKey:@"points"] != nil) [self setPoints:[[response objectForKey:@"points"] intValue]];
    if ([self body] == nil) [self setBody:[response objectForKey:@"body"]];
    if ([self posted] == nil) [self setPosted:[response objectForKey:@"ago"]];
    if ([self submitter] == nil && [response objectForKey:@"user"] != nil) [self setSubmitter:[[[HNUser alloc] initWithIdentifier:[response objectForKey:@"user"]] autorelease]];
    if ([self title] == nil) [self setTitle:[response objectForKey:@"title"]];
    if ([self destination] == nil) [self setDestination:[NSURL URLWithString:[response objectForKey:@"url"]]];
    
    if ([response objectForKey:@"parent"] != nil) {
        HNEntry *parent_ = [[HNEntry alloc] initWithIdentifier:[response objectForKey:@"parent"]];
        if ([self parent] == nil) [self setParent:[parent_ autorelease]];
    }
    
    NSArray *children_ = [response objectForKey:@"children"];
    NSMutableArray *comments = [NSMutableArray array];
    for (NSDictionary *child in children_) {
        HNEntry *entry = [[HNEntry alloc] initWithType:kHNPageTypeItemComments identifier:[child objectForKey:@"identifier"]];
        [entry loadFromDictionary:child];
        if ([child objectForKey:@"children"] != nil) [entry setLoaded:YES];
        [entry setParent:self];
        [comments addObject:[entry autorelease]];
    }
    [self setEntries:comments];
    
    if ([response objectForKey:@"numcomments"] != nil) {
        [self setChildren:[[response objectForKey:@"numcomments"] intValue]];
    } else {
        int num = 0;
        for (HNEntry *child in [self entries]) num += [child children];
        [self setChildren:num + [[self entries] count]];
    }
}

- (void)finishLoadingWithResponse:(NSDictionary *)response {
    [self loadFromDictionary:response];
}

@end
