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

@implementation MainTabBarController

- (id)init {
    if ((self = [super init])) {
        HNEntry *homeEntry = [[[HNEntry alloc] initWithType:kHNPageTypeSubmissions] autorelease];
        SubmissionListController *home = [[[SubmissionListController alloc] initWithSource:homeEntry] autorelease];
        [home setTitle:@"Hacker News"];
        [home setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"Home" image:[UIImage imageNamed:@"home.png"] tag:0] autorelease]];
        
        HNEntry *newEntry = [[[HNEntry alloc] initWithType:kHNPageTypeNewSubmissions] autorelease];
        SubmissionListController *new = [[[SubmissionListController alloc] initWithSource:newEntry] autorelease];
        [new setTitle:@"New Submissions"];
        [new setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"New" image:[UIImage imageNamed:@"new.png"] tag:0] autorelease]];
        
        SessionProfileController *profile = [[[SessionProfileController alloc] initWithSource:[[HNSession currentSession] user]] autorelease];
        [profile setTitle:@"Profile"];
        [profile setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"Profile" image:[UIImage imageNamed:@"person.png"] tag:0] autorelease]];
        
        MoreController *more = [[[MoreController alloc] init] autorelease];
        [more setTitle:@"More"];
        [more setTabBarItem:[[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:0] autorelease]];

        NSMutableArray *items = [NSMutableArray arrayWithObjects:home, new, profile, more, nil];
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
    [sheet showInView:[[self view] window]];
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
    if ([HNSession currentSession] != nil) {
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
    
    [super dealloc];
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
