//
//  InstapaperController.m
//  newsyc
//
//  Created by Grant Paul on 2/24/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "SharingController.h"

#import <MessageUI/MFMailComposeViewController.h>

#import "InstapaperLoginController.h"
#import "InstapaperRequest.h"
#import "InstapaperSession.h"

#import "InstapaperSubmission.h"
#import "InstapaperActivity.h"

#import "BarButtonItem.h"

@interface SharingController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@end

@implementation SharingController

+ (BOOL)useNativeSharing {
    return (NSClassFromString(@"UIActivityViewController") != nil);
}

- (id)initWithURL:(NSURL *)url_ title:(NSString *)title_ fromController:(UIViewController *)controller_ {
    if ((self = [super init])) {
        url = [url_ copy];
        title = [title_ copy];
        controller = controller_; // XXX: retain this?
    }

    return self;
}

- (void)dealloc {
    [url release];
    [title release];

    [super dealloc];
}

- (void)showFromView:(UIView *)view barButtonItem:(BarButtonItem *)item {
    if ([[self class] useNativeSharing]) {
        InstapaperActivity *instapaperActivity = [[InstapaperActivity alloc] init];
        NSArray *activityItems = [NSArray arrayWithObjects:url, nil];
        NSArray *applicationActivities = [NSArray arrayWithObjects:[instapaperActivity autorelease], nil];

        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
        [activityController setExcludedActivityTypes:[NSArray arrayWithObjects:UIActivityTypePrint, UIActivityTypeSaveToCameraRoll, nil]];

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:activityController];

            if (item != nil) {
                [popover presentPopoverFromBarButtonItemInWindow:item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            } else if (view != nil) {
                [popover presentPopoverFromRect:[view frame] inView:[view superview] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            } else {
                NSAssert(NO, @"You must provide a view or a bar button item to a sharing controller.");
            }

            [activityController setCompletionHandler:^(NSString *activityType, BOOL completed) {
                [popover dismissPopoverAnimated:YES];
                [popover release];
            }];
        } else {
            [controller presentModalViewController:activityController animated:YES];
        }
    } else {
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:[url absoluteString]
                                delegate:self
                                cancelButtonTitle:nil
                                destructiveButtonTitle:nil
                                otherButtonTitles:nil
                                ];

        [sheet addButtonWithTitle:@"Open with Safari"];
        if ([MFMailComposeViewController canSendMail]) [sheet addButtonWithTitle:@"Mail Link"];
        [sheet addButtonWithTitle:@"Copy Link"];
        [sheet addButtonWithTitle:@"Read Later"];
        [sheet addButtonWithTitle:@"Cancel"];
        [sheet setCancelButtonIndex:([sheet numberOfButtons] - 1)];

        if (view != nil) {
            [sheet showFromRect:[view frame] inView:[view superview] animated:YES];
        } else {
            [sheet showFromBarButtonItemInWindow:item animated:YES];
        }

        [self retain];
        [sheet release];
    }
}

- (void)showFromView:(UIView *)view {
    [self showFromView:view barButtonItem:nil];
}

- (void)showFromBarButtonItem:(BarButtonItem *)item {
    [self showFromView:nil barButtonItem:item];
}

#pragma mark - Sharing Implementations

- (void)openInSafari {
    [[UIApplication sharedApplication] openURL:url];
}

- (void)composeMail {
    MFMailComposeViewController *composeController = [[MFMailComposeViewController alloc] init];
    [composeController setMailComposeDelegate:self];

    NSString *urlString = [url absoluteString];
    NSString *body = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", urlString, urlString];
    [composeController setMessageBody:body isHTML:YES];
    [composeController setSubject:title];

    [controller presentModalViewController:composeController animated:YES];

    [self retain];
    [composeController release];
}

- (void)copyToPasteboard {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setURL:url];
    [pasteboard setString:[url absoluteString]];
}

- (void)submitToInstapaper {
    InstapaperSubmission *submission = [[InstapaperSubmission alloc] initWithURL:url];
    [submission submitFromController:controller];
    [submission release];
}

- (void)mailComposeController:(MFMailComposeViewController *)composeController didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissModalViewControllerAnimated:YES];
    [self release];
}

- (void)actionSheet:(UIActionSheet *)action clickedButtonAtIndex:(NSInteger)buttonIndex {
    BOOL canSendMail = [MFMailComposeViewController canSendMail];

    if (buttonIndex == 0) {
        [self openInSafari];
    } else if ((canSendMail && buttonIndex == 1)) {
        [self composeMail];
    } else if ((canSendMail && buttonIndex == 2) || (!canSendMail && buttonIndex == 1)) {
        [self copyToPasteboard];
    } else if ((canSendMail && buttonIndex == 3) || (!canSendMail && buttonIndex == 2)) {
        [self submitToInstapaper];
    }

    [self release];
}

@end
