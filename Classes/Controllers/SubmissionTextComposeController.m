//
//  SubmissionTextComposeController.m
//  newsyc
//
//  Created by Grant Paul on 3/31/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "SubmissionTextComposeController.h"

@implementation SubmissionTextComposeController

- (BOOL)includeMultilineEditor {
    return YES;
}

- (NSString *)multilinePlaceholder {
    return @"Post Body";
}

- (NSString *)title {
    return @"Submit Text";
}

- (NSArray *)inputEntryCells {
    UITableViewCell *cell = [self generateTextFieldCell];
    [[cell textLabel] setText:@"Title:"];
    titleField = [self generateTextFieldForCell:cell];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(titleDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [cell addSubview:titleField];
    
    return [NSArray arrayWithObject:cell];
}

- (UIResponder *)initialFirstResponder {
    return titleField;
}

- (void)submission:(id)submission performedSubmission:(NSNumber *)submitted error:(NSError *)error {
    if ([submitted boolValue]) {
        [self sendComplete];
    } else {
        [self sendFailed];
    }
}

- (void)performSubmission {
    if (![self ableToSubmit]) {
        [self sendFailed];
    } else {
        [[HNSession currentSession] submitEntryWithTitle:[titleField text] body:[textView text] URL:nil target:self action:@selector(submission:performedSubmission:error:)];
    }
}

- (BOOL)ableToSubmit {
    return !([[titleField text] length] == 0 || [[textView text] length] == 0);
}

AUTOROTATION_FOR_PAD_ONLY

@end
