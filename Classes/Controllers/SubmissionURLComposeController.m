//
//  SubmissionURLComposeController.m
//  newsyc
//
//  Created by Grant Paul on 3/31/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "SubmissionURLComposeController.h"
#import "PlaceholderTextView.h"

@implementation SubmissionURLComposeController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (nil != pasteboard.string) {
        NSDataDetector* detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        NSArray* matches = [detector matchesInString:pasteboard.string options:0 range:NSMakeRange(0, [pasteboard.string length])];
        if ([matches count] > 0) {            
            textView.text = [[[matches objectAtIndex:0] URL] absoluteString];
        }
    }
}

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

- (BOOL)ableToSubmit {
    NSURL *url = [NSURL URLWithString:[textView text]];
    return !([[titleField text] length] == 0 || [[textView text] length] == 0 || url == nil);
}

AUTOROTATION_FOR_PAD_ONLY

@end
