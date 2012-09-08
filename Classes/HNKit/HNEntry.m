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
    // This is counterintuitive, but we are essentially checking for a parent.
    return [self submission] == nil;
}

- (void)loadContentsDictionary:(NSDictionary *)contents entries:(NSArray **)outEntries {
    if ([contents objectForKey:@"submission"]) {
        [self setSubmission:[HNEntry entryWithIdentifier:[contents objectForKey:@"submission"]]];
    }

    id parentId = [contents objectForKey:@"parent"];
    if (parentId) {
        HNEntry *parent_ = [HNEntry entryWithIdentifier:parentId];
        
        // Set the submission property on the parent, as long as that's not the submission itself
        // (we want all submission objects to have a submission property value of nil)
        if (![parentId isEqual:[[self submission] identifier]]) {
            [parent_ setSubmission:[self submission]];
        }
        
        [self setParent:parent_];
    }

    [self loadContentsDictionary:contents entries:outEntries withSubmission:[self submission] ?: self];
}

- (void)loadContentsDictionary:(NSDictionary *)contents entries:(NSArray **)outEntries withSubmission:(HNEntry *)submission_ {
    if ([contents objectForKey:@"url"] != nil) [self setDestination:[NSURL URLWithString:[contents objectForKey:@"url"]]];
    if ([contents objectForKey:@"user"] != nil) [self setSubmitter:[HNUser userWithIdentifier:[contents objectForKey:@"user"]]];
    if ([contents objectForKey:@"body"] != nil) [self setBody:[contents objectForKey:@"body"]];
    if ([contents objectForKey:@"date"] != nil) [self setPosted:[contents objectForKey:@"date"]];
    if ([contents objectForKey:@"title"] != nil) [self setTitle:[contents objectForKey:@"title"]];
    if ([contents objectForKey:@"points"] != nil) [self setPoints:[[contents objectForKey:@"points"] intValue]];
    
    NSMutableArray *comments = [NSMutableArray array];    
    if ([contents objectForKey:@"children"] != nil) {
        for (NSDictionary *child in [contents objectForKey:@"children"]) {
            HNEntry *childEntry = [HNEntry entryWithIdentifier:[child objectForKey:@"identifier"]];
            NSArray *childEntries = nil;
            
            [childEntry loadContentsDictionary:child entries:&childEntries withSubmission:submission_];
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
    
    if ([contents objectForKey:@"numchildren"] != nil) {
        int count = [[contents objectForKey:@"numchildren"] intValue];
        [self setChildren:count];
    } else {
        int count = [comments count];
        for (HNEntry *child in comments)
            count += [child children];
        [self setChildren:count];
    }
}

- (NSDictionary *)contentsDictionary {
    NSMutableDictionary *dictionary = [[[super contentsDictionary] mutableCopy] autorelease];

    if (destination != nil) [dictionary setObject:destination forKey:@"url"];
    if (submitter != nil) [dictionary setObject:[submitter identifier] forKey:@"user"];
    if (body != nil) [dictionary setObject:body forKey:@"body"];
    if (posted != nil) [dictionary setObject:posted forKey:@"date"];
    if (title != nil) [dictionary setObject:title forKey:@"title"];
    [dictionary setObject:[NSNumber numberWithInt:points] forKey:@"points"];
    [dictionary setObject:[NSNumber numberWithInt:children] forKey:@"numchildren"];

    return dictionary;
}

@end
