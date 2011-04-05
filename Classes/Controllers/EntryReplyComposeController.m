//
//  EntryReplyComposeController.m
//  newsyc
//
//  Created by Grant Paul on 3/31/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "EntryReplyComposeController.h"

@implementation EntryReplyComposeController
@synthesize entry;

- (id)initWithEntry:(HNEntry *)entry_ {
    if ((self = [super init])) {
        entry = entry_;
    }
    
    return self;
}

- (BOOL)includeMultilineEditor {
    return YES;
}

- (NSString *)multilinePlaceholder {
    // This is shown only when the controller is first animating in,
    // so a placeholder actually makes it look worse in this case.
    return @"";
}

- (NSString *)title {
    return @"Reply";
}

- (UIResponder *)initialFirstResponder {
    return (UIResponder *) textView;
}

- (void)submission:(id)submission performedReply:(NSNumber *)submitted error:(NSError *)error {
    if ([submitted boolValue]) {
        [self sendComplete];
    } else {
        [self sendFailed];
    }
}

- (void)performSubmission {
    if ([[textView text] length] == 0) {
        [self sendFailed];
    } else {
        [[HNSession currentSession] replyToEntry:entry withBody:[textView text] target:self action:@selector(submission:performedReply:error:)];
    }
}

@end
