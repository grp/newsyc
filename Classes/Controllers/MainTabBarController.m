//
//  MainTabBarController.m
//  newsyc
//
//  Created by Grant Paul on 3/30/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"

#import "UIActionSheet+Context.h"

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

@implementation MainTabBarController

- (id)init {
    if ((self = [super init])) {
        HNEntry *homeEntry = [[[HNEntry alloc] initWithType:kHNPageTypeSubmissions] autorelease];
        home = [[[SubmissionListController alloc] initWithSource:homeEntry] autorelease];
        [home setTitle:@"Hacker News"];
        [home setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"Home" image:[UIImage imageNamed:@"home.png"] tag:0] autorelease]];
        
        HNEntry *newEntry = [[[HNEntry alloc] initWithType:kHNPageTypeNewSubmissions] autorelease];
        latest = [[[SubmissionListController alloc] initWithSource:newEntry] autorelease];
        [latest setTitle:@"New Submissions"];
        [latest setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"New" image:[UIImage imageNamed:@"new.png"] tag:0] autorelease]];
        
        profile = [[[SessionProfileController alloc] initWithSource:[[HNSession currentSession] user]] autorelease];
        [profile setTitle:@"Profile"];
        [profile setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"Profile" image:[UIImage imageNamed:@"person.png"] tag:0] autorelease]];

        search = [[[SearchController alloc] init] autorelease];
        [search setTitle:@"Search"];
        [search setTabBarItem:[[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0] autorelease]];

        more = [[[MoreController alloc] init] autorelease];
        [more setTitle:@"More"];
        [more setTabBarItem:[[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:0] autorelease]];

        NSMutableArray *items = [NSMutableArray arrayWithObjects:home, latest, search, profile, more, nil];
        [self setViewControllers:items];
    }
    
    return self;
}

- (void)actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(NSInteger)index {
    if ([[sheet sheetContext] isEqual:@"compose"]) {
        if (index == [sheet cancelButtonIndex]) return;
        
        NavigationController *navigation = [[NavigationController alloc] init];
        ComposeController *compose = nil;
        if (index == 0) {
            compose = [[SubmissionURLComposeController alloc] init];
        } else {
            compose = [[SubmissionTextComposeController alloc] init];
        }
        [navigation setViewControllers:[NSArray arrayWithObject:[compose autorelease]]];
        [self presentModalViewController:[navigation autorelease] animated:YES];
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [sheet showFromBarButtonItem:composeItem animated:YES];
    else [sheet showInView:[[self view] window]];
    [sheet release];
}

- (void)loginControllerDidLogin:(LoginController *)controller {
    [self dismissModalViewControllerAnimated:YES];
    [self requestSubmissionType];
}

- (void)loginControllerDidCancel:(LoginController *)controller {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)composePressed {
    if (![[HNSession currentSession] isAnonymous]) {
        [self requestSubmissionType];
    } else {
        LoginController *login = [[HackerNewsLoginController alloc] init];
        [login setDelegate:self];
        NavigationController *navigation = [[NavigationController alloc] initWithRootViewController:[login autorelease]];
        [self presentModalViewController:[navigation autorelease] animated:YES];
    }
}

- (void)dealloc {
    [composeItem release];
    [lastSeen release];
    
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [lastSeen release];
    lastSeen = [[NSDate date] retain];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // XXX: is 15 inutes the optimal time here?
    if ([lastSeen timeIntervalSinceNow] < -(15 * 60)) {
        [[home source] beginReloading];
        [[latest source] beginReloading];
    }
        
    [lastSeen release];
    lastSeen = [[NSDate date] retain];
}

- (void)loadView {
    [super loadView];
    
    composeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composePressed)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationItem] setRightBarButtonItem:composeItem];
}

@end
