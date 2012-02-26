//
//  HNEntry.h
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNShared.h"
#import "HNContainer.h"

@class HNUser;
@interface HNEntry : HNContainer {
    int points;
    int children;
    HNUser *submitter;
    NSString *body;
    NSString *posted;
    HNEntry *parent;
    HNEntry *submission;
    NSURL *destination;
    NSString *title;
}

@property (nonatomic, assign) int points;
@property (nonatomic, assign) int children;
@property (nonatomic, retain) HNUser *submitter;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, retain) NSString *posted;
@property (nonatomic, retain) HNEntry *parent;
@property (nonatomic, retain) HNEntry *submission;
@property (nonatomic, copy) NSURL *destination;
@property (nonatomic, copy) NSString *title;

- (void)loadFromDictionary:(NSDictionary *)response entries:(NSArray **)outEntries withSubmission:(HNEntry *)submission_;

- (BOOL)isComment;
- (BOOL)isSubmission;

+ (id)entryWithIdentifier:(id)identifier_;

@end
