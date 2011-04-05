//
//  HNEntry.h
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNObject.h"

@class HNUser;
@interface HNEntry : HNObject {
    int points;
    int children;
    HNUser *submitter;
    NSString *body;
    NSString *posted;
    HNEntry *parent;
    NSMutableArray *entries;
    NSURL *destination;
    NSString *title;
    NSString *more;
}

@property (nonatomic, assign) int points;
@property (nonatomic, assign) int children;
@property (nonatomic, retain) HNUser *submitter;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, retain) NSString *posted;
@property (nonatomic, retain) HNEntry *parent;
@property (nonatomic, retain) NSArray *entries;
@property (nonatomic, copy) NSURL *destination;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *more;

- (void)loadFromDictionary:(NSDictionary *)response;

@end
