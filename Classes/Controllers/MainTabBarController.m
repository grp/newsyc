//
//  MainTabBarController.m
//  newsyc
//
//  Created by Grant Paul on 3/30/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import <HNKit/HNKit.h>

#import "UIActionSheet+Context.h"
#import "UIColor+Orange.h"

#import "MainTabBarController.h"
#import "SubmissionListController.h"
#import "SessionProfileController.h"
#import "MoreController.h"
#import "NavigationController.h"
#import "ComposeController.h"
#import "SubmissionTextComposeController.h"
#import "SubmissionURLComposeController.h"
#import "HackerNewsLoginController.h"
#import "LoginController.h"
#import "SearchController.h"
#import "CustomLayoutGuide.h"

#import "HNTimeline.h"

@implementation MainTabBarController

- (id)initWithSession:(HNSession *)session_ {
    if ((self = [super init])) {
        session = [session_ retain];

        if (![session isAnonymous] && [[HNSessionController sessionController] numberOfSessions] != 1) {
            [self setTitle:[[session user] identifier]];
        } else {
            [self setTitle:@"Hacker News"];
        }

        HNEntryList *homeList = [HNEntryList session:session entryListWithIdentifier:kHNEntryListIdentifierSubmissions];
        home = [[[SubmissionListController alloc] initWithSource:homeList] autorelease];
        [home setTitle:@"Hacker News"];
        [home setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"Home" image:[UIImage imageNamed:@"home.png"] tag:0] autorelease]];
        
        HNEntryList *newList = [HNEntryList session:session entryListWithIdentifier:kHNEntryListIdentifierNewSubmissions];
        latest = [[[SubmissionListController alloc] initWithSource:newList] autorelease];
        [latest setTitle:@"New Submissions"];
        [latest setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"New" image:[UIImage imageNamed:@"new.png"] tag:0] autorelease]];
    
#ifdef ENABLE_TIMELINE
        HNEntryList *newList = [HNTimeline timelineForSession:session];
        latest = [[[CommentListController alloc] initWithSource:newList] autorelease];
        [latest setTitle:@"Timeline"];
        [latest setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"Timeline" image:[UIImage imageNamed:@"new.png"] tag:0] autorelease]];
#endif

        profile = [[[SessionProfileController alloc] initWithSource:[session user]] autorelease];
        [profile setTitle:@"Profile"];
        [profile setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"Profile" image:[UIImage imageNamed:@"person.png"] tag:0] autorelease]];

        search = [[[SearchController alloc] initWithSession:session] autorelease];
        [search setTitle:@"Search"];
        [search setTabBarItem:[[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0] autorelease]];

        more = [[[MoreController alloc] initWithSession:session] autorelease];
        [more setTitle:@"More"];
        [more setTabBarItem:[[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:0] autorelease]];

        NSMutableArray *items = [NSMutableArray arrayWithObjects:home, latest, profile, search, more, nil];
        [self setViewControllers:items];
        
        [self setDelegate:self];
    }
    
    return self;
}

- (void)actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(NSInteger)index {
    if ([[sheet sheetContext] isEqual:@"compose"]) {
        if (index == [sheet cancelButtonIndex]) return;
        
        NavigationController *navigation = [[NavigationController alloc] init];
        ComposeController *compose = nil;
        
        if (index == 0) {
            compose = [[SubmissionURLComposeController alloc] initWithSession:session];
        } else {
            compose = [[SubmissionTextComposeController alloc] initWithSession:session];
        }
        
        [navigation setViewControllers:[NSArray arrayWithObject:compose]];
        [self presentViewController:navigation animated:YES completion:NULL];

        [navigation release];
        [compose release];
    }
}

- (void)requestSubmissionType {
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    
    [sheet addButtonWithTitle:@"Submit URL"];
    [sheet addButtonWithTitle:@"Submit Text"];
    [sheet addButtonWithTitle:@"Cancel"];
    [sheet setCancelButtonIndex:2];
    [sheet setSheetContext:@"compose"];
    [sheet setDelegate:self];
    
    [sheet showFromBarButtonItemInWindow:composeItem animated:YES];
    [sheet release];
}

- (void)updateLayoutForViewController:(UIViewController *)viewController {
    if ([self respondsToSelector:@selector(topLayoutGuide)] && [self respondsToSelector:@selector(bottomLayoutGuide)]) {
        CustomLayoutGuide *topLayoutGuide = [[CustomLayoutGuide alloc] init];
        [topLayoutGuide setLength:self.topLayoutGuide.length];
        [viewController setValue:topLayoutGuide forKey:@"topLayoutGuide"];
        [topLayoutGuide release];

        CustomLayoutGuide *bottomLayoutGuide = [[CustomLayoutGuide alloc] init];
        [bottomLayoutGuide setLength:(self.bottomLayoutGuide.length + self.tabBar.bounds.size.height)];
        [viewController setValue:bottomLayoutGuide forKey:@"bottomLayoutGuide"];
        [bottomLayoutGuide release];

        [[viewController view] setNeedsLayout];
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [self updateLayoutForViewController:viewController];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (viewController == profile && [session isAnonymous]) {
        [[self navigationController] requestLogin];

        return NO;
	}
    
    return YES;
}

- (void)composePressed {
    if (![session isAnonymous]) {
        [self requestSubmissionType];
    } else {
        [[self navigationController] requestLogin];
    }
}

- (void)dealloc {
    [composeItem release];
    [session release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // XXX: Fix iOS 6 bug with a tab bar controller in a navigation controller.
    [self setViewControllers:[self viewControllers]];
    [[self selectedViewController] setWantsFullScreenLayout:YES];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disable-orange"]) {
        if ([[self tabBar] respondsToSelector:@selector(setBarTintColor:)]) {
            [[self tabBar] setTintColor:[UIColor mainOrangeColor]];
        } else {
            [[self tabBar] setSelectedImageTintColor:[UIColor mainOrangeColor]];
        }
    } else {
        if ([[self tabBar] respondsToSelector:@selector(setBarTintColor:)]) {
            [[self tabBar] setTintColor:nil];
        }

        [[self tabBar] setSelectedImageTintColor:nil];
    }
}

- (void)loadView {
    [super loadView];
    
    composeItem = [[BarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composePressed)];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [[self navigationItem] setRightBarButtonItem:nil];
    
    [composeItem release];
    composeItem = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationItem] setRightBarButtonItem:composeItem];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self updateLayoutForViewController:self.selectedViewController];
}

AUTOROTATION_FOR_PAD_ONLY

@end
