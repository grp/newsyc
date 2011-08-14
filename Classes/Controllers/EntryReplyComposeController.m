//
//  EntryReplyComposeController.m
//  newsyc
//
//  Created by Grant Paul on 3/31/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "EntryReplyComposeController.h"
#import "PlaceholderTextView.h"

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

- (void)replySucceededWithNotification:(NSNotification *)notification {
    [self sendComplete];
}

- (void)replyFailedWithNotification:(NSNotification *)notification {
    [self sendFailed];
}

- (void)performSubmission {
    if (![self ableToSubmit]) {
        [self sendFailed];
    } else {
        HNSubmission *submission = [[HNSubmission alloc] initWithSubmissionType:kHNSubmissionTypeReply];
        [submission setBody:[textView text]];
        [submission setTarget:entry];
        [[HNSession currentSession] performSubmission:submission];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replySucceededWithNotification:) name:kHNSubmissionSuccessNotification object:submission];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replyFailedWithNotification:) name:kHNSubmissionFailureNotification object:submission];
        [submission release];
    }
}

- (BOOL)ableToSubmit {
    return [[textView text] length] > 0;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

AUTOROTATION_FOR_PAD_ONLY

@end
