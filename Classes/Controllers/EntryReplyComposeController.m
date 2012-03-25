//
//  EntryReplyComposeController.m
//  newsyc
//
//  Created by Grant Paul on 3/31/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "EntryReplyComposeController.h"
#import "PlaceholderTextView.h"

#import "NSString+Entities.h"
#import "NSString+Tags.h"

@implementation EntryReplyComposeController
@synthesize entry;

- (id)initWithEntry:(HNEntry *)entry_ {
    if ((self = [super init])) {
        entry = [entry_ retain];
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHNSubmissionSuccessNotification object:[notification object]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHNSubmissionFailureNotification object:[notification object]];
}

- (void)replyFailedWithNotification:(NSNotification *)notification {
    [self sendFailed];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHNSubmissionSuccessNotification object:[notification object]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHNSubmissionFailureNotification object:[notification object]];
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

- (void)loadView {
    [super loadView];
    
    replyLabel = [[UILabel alloc] init];
    [replyLabel setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth];
    [replyLabel setTextAlignment:UITextAlignmentLeft];
    [replyLabel setLineBreakMode:UILineBreakModeWordWrap];
    [replyLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [replyLabel setTextColor:[UIColor darkGrayColor]];
    [replyLabel setNumberOfLines:0];
    [tableView addSubview:replyLabel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([entry body] != nil && ![[entry body] isEqualToString:@""]) {
        CGFloat replyPadding = 8.0f;
        
        NSString *bodyText = [entry body];
        bodyText = [bodyText stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n\n"];
        bodyText = [bodyText stringByRemovingHTMLTags];
        bodyText = [bodyText stringByDecodingHTMLEntities];
        bodyText = [bodyText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        NSString *replyText = [NSString stringWithFormat:@"%@: %@", [[entry submitter] identifier], bodyText];
        [replyLabel setText:replyText];
        
        CGRect replyFrame = CGRectMake(replyPadding, -replyPadding, [tableView bounds].size.width - replyPadding - replyPadding, [tableView bounds].size.height / 3.0f);
        replyFrame.size.height = [[replyLabel text] sizeWithFont:[replyLabel font] constrainedToSize:replyFrame.size lineBreakMode:[replyLabel lineBreakMode]].height;
        replyFrame.origin.y -= replyFrame.size.height;
        [replyLabel setFrame:replyFrame];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [replyLabel release];
    replyLabel = nil;
}

- (BOOL)ableToSubmit {
    return [[textView text] length] > 0;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHNSubmissionSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHNSubmissionFailureNotification object:nil];
    
    [replyLabel release];
    [entry release];
    
    [super dealloc];
}

AUTOROTATION_FOR_PAD_ONLY

@end
