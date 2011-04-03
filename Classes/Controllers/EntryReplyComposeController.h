//
//  EntryReplyComposeController.h
//  newsyc
//
//  Created by Grant Paul on 3/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ComposeController.h"

@interface EntryReplyComposeController : ComposeController {
    HNEntry *entry;
}

@property (nonatomic, readonly) HNEntry *entry;

- (id)initWithEntry:(HNEntry *)entry_;

@end
