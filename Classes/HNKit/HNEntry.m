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
#import "HNObjectBodyRenderer.h"
#endif

@implementation HNEntry
@synthesize points, children, submitter, body, posted, parent, submission, title, destination;

#ifdef HNKIT_RENDERING_ENABLED
@synthesize renderer;

- (HNObjectBodyRenderer *)renderer {
    if (renderer != nil) return renderer;
    
    renderer = [[HNObjectBodyRenderer alloc] initWithObject:self];
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

+ (id)session:(HNSession *)session entryWithIdentifier:(id)identifier_ {
    return [self session:session objectWithIdentifier:identifier_];
}

- (BOOL)isComment {
    return ![self isSubmission];
}

- (BOOL)isSubmission {
    // Checking submission rather than something like title since this will be set
    // even when the entry hasn't been loaded.
    return [self submission] == nil;
}

- (void)loadFromDictionary:(NSDictionary *)response complete:(BOOL)complete {
    if ([response objectForKey:@"submission"]) {
        [self setSubmission:[HNEntry session:session entryWithIdentifier:[response objectForKey:@"submission"]]];
    }

    if ([response objectForKey:@"parent"]) {
        [self setParent:[HNEntry session:session entryWithIdentifier:[response objectForKey:@"parent"]]];

        // Set the submission property on the parent, as long as that's not the submission itself
        // (we want all submission objects to have a submission property value of nil)
        if (![[[self parent] identifier] isEqual:[[self submission] identifier]]) {
            [[self parent] setSubmission:[self submission]];
        }
    }

    if ([response objectForKey:@"url"] != nil) [self setDestination:[NSURL URLWithString:[response objectForKey:@"url"]]];
    if ([response objectForKey:@"user"] != nil) [self setSubmitter:[HNUser session:session userWithIdentifier:[response objectForKey:@"user"]]];
    if ([response objectForKey:@"body"] != nil) [self setBody:[response objectForKey:@"body"]];
    if ([response objectForKey:@"date"] != nil) [self setPosted:[response objectForKey:@"date"]];
    if ([response objectForKey:@"title"] != nil) [self setTitle:[response objectForKey:@"title"]];
    if ([response objectForKey:@"points"] != nil) [self setPoints:[[response objectForKey:@"points"] intValue]];
    
    if ([response objectForKey:@"children"] != nil) {
        NSMutableArray *comments = [NSMutableArray array];

        for (NSDictionary *child in [response objectForKey:@"children"]) {
            HNEntry *childEntry = [HNEntry session:session entryWithIdentifier:[child objectForKey:@"identifier"]];
            
            [childEntry setParent:self];
            [childEntry setSubmission:[self submission] ?: self];

            BOOL complete = ([child objectForKey:@"children"] != nil);
            [childEntry loadFromDictionary:child complete:complete];

            [comments addObject:childEntry];
        }

        NSArray *allEntries = [(pendingMoreEntries ? : [NSArray array]) arrayByAddingObjectsFromArray:comments];
        [self setEntries:allEntries];
    }
    
    if ([response objectForKey:@"numchildren"] != nil) {
        NSInteger count = [[response objectForKey:@"numchildren"] intValue];
        [self setChildren:count];
    } else {
        NSInteger count = [[self entries] count];
        
        for (HNEntry *child in [self entries]) {
            count += [child children];
        }
        
        [self setChildren:count];
    }

    [super loadFromDictionary:response complete:complete];
}

@end
