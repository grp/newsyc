//
//  EntryReplyComposeController.h
//  newsyc
//
//  Created by Grant Paul on 3/31/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "ComposeController.h"

@interface EntryReplyComposeController : ComposeController {
    HNEntry *entry;
    UILabel *replyLabel;
}

@property (nonatomic, readonly, retain) HNEntry *entry;

- (id)initWithEntry:(HNEntry *)entry_;

@end
