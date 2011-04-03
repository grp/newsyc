//
//  SubmissionURLComposeController.m
//  newsyc
//
//  Created by Grant Paul on 3/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SubmissionURLComposeController.h"

@implementation SubmissionURLComposeController

- (BOOL)includeMultilineEditor {
    return YES;
}

- (NSString *)multilinePlaceholder {
    return @"URL";
}

- (NSString *)title {
    return @"Submit URL";
}

- (NSArray *)inputEntryCells {
    UITableViewCell *cell = [self generateTextFieldCell];
    [[cell textLabel] setText:@"Title:"];
    titleField = [self generateTextFieldForCell:cell];
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
    NSURL *url = [NSURL URLWithString:[textView text]];
    
    if ([[titleField text] length] == 0 || [[textView text] length] == 0 || url == nil) {
        [self sendFailed];
    } else {
        [[HNSession currentSession] submitEntryWithTitle:[titleField text] body:nil URL:nil target:self action:@selector(submission:performedSubmission:error:)];
    }
}

@end
