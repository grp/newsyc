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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [cell addSubview:titleField];
    
    return [NSArray arrayWithObject:cell];
}

- (UIResponder *)initialFirstResponder {
    return titleField;
}

- (void)submissionSucceededWithNotification:(NSNotification *)notification {
    [self sendComplete];
}

- (void)submissionFailedWithNotification:(NSNotification *)notification {
    [self sendFailed];
}

- (void)performSubmission {
    if (![self ableToSubmit]) {
        [self sendFailed];
    } else {
        HNSubmission *submission = [[HNSubmission alloc] initWithSubmissionType:kHNSubmissionTypeSubmission];
        [submission setTitle:[titleField text]];
        [submission setDestination:[NSURL URLWithString:[textView text]]];
        [[HNSession currentSession] performSubmission:submission];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submissionSucceededWithNotification:) name:kHNSubmissionSuccessNotification object:submission];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submissionFailedWithNotification:) name:kHNSubmissionFailureNotification object:submission];
        [submission release];
    }
}

- (BOOL)ableToSubmit {
    NSURL *url = [NSURL URLWithString:[textView text]];
    return !([[titleField text] length] == 0 || [[textView text] length] == 0 || url == nil);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHNSubmissionSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHNSubmissionFailureNotification object:nil];
    
    [super dealloc];
}

AUTOROTATION_FOR_PAD_ONLY

@end
