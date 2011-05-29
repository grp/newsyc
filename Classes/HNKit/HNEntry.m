//
//  HNEntry.m
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "NSURL+Parameters.h"

#import "HNKit.h"
#import "HNEntry.h"

@implementation HNEntry
@synthesize points, children, submitter, body, posted, parent, title, destination, entries, more;

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
    if ([response objectForKey:@"url"] != nil) [self setDestination:[NSURL URLWithString:[response objectForKey:@"url"]]];
    if ([response objectForKey:@"user"] != nil) [self setSubmitter:[[[HNUser alloc] initWithIdentifier:[response objectForKey:@"user"]] autorelease]];
    if ([response objectForKey:@"body"] != nil) [self setBody:[response objectForKey:@"body"]];
    if ([response objectForKey:@"date"] != nil) [self setPosted:[response objectForKey:@"date"]];
    if ([response objectForKey:@"title"] != nil) [self setTitle:[response objectForKey:@"title"]];
    if ([response objectForKey:@"points"] != nil) [self setPoints:[[response objectForKey:@"points"] intValue]];
    if ([response objectForKey:@"parent"] != nil) [self setParent:[[[HNEntry alloc] initWithIdentifier:[response objectForKey:@"parent"]] autorelease]];
    
    [self setMore:[response objectForKey:@"more"]];
    
    NSMutableArray *comments = [NSMutableArray array];
    for (NSDictionary *child in [response objectForKey:@"children"]) {
        HNEntry *entry = [[HNEntry alloc] initWithType:kHNPageTypeItemComments identifier:[child objectForKey:@"identifier"]];
        [entry loadFromDictionary:child];
        [entry setParent:self];
        
        if ([child objectForKey:@"children"] != nil) {
            [entry clearLoadingState:kHNObjectLoadingStateUnloaded];
            [entry clearLoadingState:kHNObjectLoadingStateNotLoaded];
            [entry addLoadingState:kHNObjectLoadingStateLoaded];
        } else {
            [entry clearLoadingState:kHNObjectLoadingStateLoaded];
            [entry addLoadingState:kHNObjectLoadingStateUnloaded];
        }
        
        [comments addObject:[entry autorelease]];
    }
     
    if ([[response objectForKey:@"append"] boolValue]) {
        [self setEntries:[[self entries] arrayByAddingObjectsFromArray:comments]];
    } else {
        [self setEntries:comments];
    }
    
    if ([response objectForKey:@"numchildren"] != nil) {
        int count = [[response objectForKey:@"numchildren"] intValue];
        [self setChildren:count];
    } else {
        int count = [[self entries] count];
        for (HNEntry *child in [self entries])
            count += [child children];
        [self setChildren:count];
    }
}

- (void)finishLoadingWithResponse:(NSDictionary *)response error:(NSError *)error {
    if (error == nil) {
        [self loadFromDictionary:response];
    }
}

@end
