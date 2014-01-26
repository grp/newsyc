//
//  InstapaperController.m
//  newsyc
//
//  Created by Grant Paul on 2/24/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "SharingController.h"
#import "CommentListController.h"

#import <MessageUI/MFMailComposeViewController.h>

#import "InstapaperLoginController.h"
#import "InstapaperRequest.h"
#import "InstapaperSession.h"

#import "InstapaperSubmission.h"
#import "InstapaperActivity.h"

#import "OpenInSafariActivity.h"

#import "BarButtonItem.h"

@interface SharingController ()
    - (NSString *) getSubject;
@end

@implementation SharingController

- (id)initWithURL:(NSURL *)url_ title:(NSString *)title_ fromController:(UIViewController *)controller_ {
    if ((self = [super init])) {
        url = [url_.absoluteURL copy];
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

- (void)showFromView:(UIView *)view barButtonItem:(BarButtonItem *)item atRect:(CGRect)rect {
    if (CGRectIsNull(rect)) {
        rect = [view frame];
    } else {
        rect = [[view superview] convertRect:rect fromView:view];
    }

    if (controller == nil) {
        controller = [[view window] rootViewController];
    }

    InstapaperActivity *instapaperActivity = [[InstapaperActivity alloc] init];
    OpenInSafariActivity *openInSafariActivity = [[OpenInSafariActivity alloc] init];
    
    NSArray *activityItems = [NSArray arrayWithObject:url];
    NSArray *applicationActivities = [NSArray arrayWithObjects:instapaperActivity, openInSafariActivity, nil];

    [instapaperActivity release];
    [openInSafariActivity release];

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
    [activityController setValue:[self getSubject] forKey:@"subject"];

    NSMutableArray *excludedActivityTypes = [NSMutableArray array];
    [excludedActivityTypes addObject:UIActivityTypePrint];
    [excludedActivityTypes addObject:UIActivityTypeSaveToCameraRoll];
    [excludedActivityTypes addObject:UIActivityTypeMessage];
    if ([UIActivityViewController instancesRespondToSelector:@selector(topLayoutGuide)]) {
        [excludedActivityTypes addObject:UIActivityTypePostToFlickr];
        [excludedActivityTypes addObject:UIActivityTypePostToVimeo];
        [excludedActivityTypes addObject:UIActivityTypeAirDrop];
    }
    [activityController setExcludedActivityTypes:excludedActivityTypes];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:activityController];

        if (item != nil) {
            [popover presentPopoverFromBarButtonItemInWindow:item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else if (view != nil) {
            [popover presentPopoverFromRect:rect inView:[view superview] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else {
            NSAssert(NO, @"You must provide a view or a bar button item to a sharing controller.");
        }

        [activityController setCompletionHandler:^(NSString *activityType, BOOL completed) {
            [popover dismissPopoverAnimated:YES];
            [popover release];
        }];
    } else {
        [controller presentViewController:activityController animated:YES completion:NULL];
    }
}

- (void)showFromView:(UIView *)view {
    [self showFromView:view barButtonItem:nil atRect:CGRectNull];
}

- (void)showFromView:(UIView *)view atRect:(CGRect)rect {
    [self showFromView:view barButtonItem:nil atRect:rect];
}

- (void)showFromBarButtonItem:(BarButtonItem *)item {
    [self showFromView:nil barButtonItem:item atRect:CGRectNull];
}

- (NSString *) getSubject {
    if ([controller isKindOfClass:[CommentListController class]]) {
        return [title stringByAppendingString:@" | Hacker News"];
    } else {
        return title;
    }
}

@end
