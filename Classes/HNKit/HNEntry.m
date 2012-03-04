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

#ifdef HNKIT_RENDERING_ENABLED
#import "HNEntryBodyRenderer.h"
#endif

@implementation HNEntry
@synthesize points, children, submitter, body, posted, parent, submission, title, destination;

#ifdef HNKIT_RENDERING_ENABLED
@synthesize renderer;

- (HNEntryBodyRenderer *)renderer {
    if (renderer != nil) return renderer;
    
    renderer = [[HNEntryBodyRenderer alloc] initWithEntry:self];
    return renderer;
}
#endif

+ (id)identifierForURL:(NSURL *)url_ {
    if (![self isValidURL:url_]) return NO;
    
    NSDictionary *parameters = [url_ parameterDictionary];
    return [NSNumber numberWithInt:[[parameters objectForKey:@"id"] intValue]];
}

+ (NSString *)pathForURLWithIdentifier:(id)identifier_ infoDictionary:(NSDictionary *)info {
    return @"item";
}

+ (NSDictionary *)parametersForURLWithIdentifier:(id)identifier_ infoDictionary:(NSDictionary *)info {
    return [NSDictionary dictionaryWithObject:identifier_ forKey:@"id"];
}

+ (id)entryWithIdentifier:(id)identifier_ {
    return [self objectWithIdentifier:identifier_];
}

- (BOOL)isComment {
    return ![self isSubmission];
}

- (BOOL)isSubmission {
    // Checking submission rather than something like title since this will be set
    // even when the entry hasn't been loaded.
    return [self submission] == nil;
}

- (void)loadFromDictionary:(NSDictionary *)response entries:(NSArray **)outEntries {
    if ([response objectForKey:@"submission"]) {
        [self setSubmission:[HNEntry entryWithIdentifier:[response objectForKey:@"submission"]]];
    }

    id parentId = [response objectForKey:@"parent"];
    if (parentId) {
        HNEntry *parent_ = [HNEntry entryWithIdentifier:parentId];
        
        // Set the submission property on the parent, as long as that's not the submission itself
        // (we want all submission objects to have a submission property value of nil)
        if (![parentId isEqual:[[self submission] identifier]]) {
            [parent_ setSubmission:[self submission]];
        }
        
        [self setParent:parent_];
    }

    [self loadFromDictionary:response entries:outEntries withSubmission:[self submission] ?: self];
}

- (void)loadChildrenFromDictionary:(NSDictionary *)response {
}

- (void)loadFromDictionary:(NSDictionary *)response entries:(NSArray **)outEntries withSubmission:(HNEntry *)submission_ {
    if ([response objectForKey:@"url"] != nil) [self setDestination:[NSURL URLWithString:[response objectForKey:@"url"]]];
    if ([response objectForKey:@"user"] != nil) [self setSubmitter:[HNUser userWithIdentifier:[response objectForKey:@"user"]]];
    if ([response objectForKey:@"body"] != nil) [self setBody:[response objectForKey:@"body"]];
    if ([response objectForKey:@"date"] != nil) [self setPosted:[response objectForKey:@"date"]];
    if ([response objectForKey:@"title"] != nil) [self setTitle:[response objectForKey:@"title"]];
    if ([response objectForKey:@"points"] != nil) [self setPoints:[[response objectForKey:@"points"] intValue]];
    
    NSMutableArray *comments = [NSMutableArray array];    
    if ([response objectForKey:@"children"] != nil) {
        for (NSDictionary *child in [response objectForKey:@"children"]) {
            HNEntry *childEntry = [HNEntry entryWithIdentifier:[child objectForKey:@"identifier"]];
            NSArray *childEntries = nil;
            
            [childEntry loadFromDictionary:child entries:&childEntries withSubmission:submission_];
            [childEntry setEntries:childEntries];
            [childEntry setParent:self];
            [childEntry setSubmission:submission_];
            
            if ([child objectForKey:@"children"] != nil) {
                [childEntry setIsLoaded:YES];
            } else {
                [childEntry setIsLoaded:NO];
            }
            
            [comments addObject:childEntry];
        }
        
        if (outEntries != NULL) {
            *outEntries = comments;
        }
    }
    
    if ([response objectForKey:@"numchildren"] != nil) {
        int count = [[response objectForKey:@"numchildren"] intValue];
        [self setChildren:count];
    } else {
        int count = [comments count];
        for (HNEntry *child in comments)
            count += [child children];
        [self setChildren:count];
    }
}

@end
