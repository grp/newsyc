//
//  HNEntry.h
//  Orangey
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HNObject.h"

@class HNUser;
@interface HNEntry : HNObject {
    int points;
    int numchildren;
    NSArray *children;
    HNUser *submitter;
    NSString *body;
    NSString *posted;
    HNEntry *parent;
    NSURL *destination;
    NSString *title;
}

@property (nonatomic, assign) int points;
@property (nonatomic, assign) int numchildren;
@property (nonatomic, retain) NSArray *children;
@property (nonatomic, retain) HNUser *submitter;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, retain) NSString *posted;
@property (nonatomic, retain) HNEntry *parent;
@property (nonatomic, copy) NSURL *destination;
@property (nonatomic, copy) NSString *title;

- (void)loadFromDictionary:(NSDictionary *)response;

@end
