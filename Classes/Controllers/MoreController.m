//
//  MoreController.m
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"

#import "MoreController.h"
#import "ProfileController.h"
#import "ProfileHeaderView.h"
#import "SubmissionListController.h"
#import "CommentListController.h"
#import "BrowserController.h"

@implementation MoreController

- (void)dealloc {
    [tableView release];
    
    [super dealloc];
}

- (void)loadView {
    [super loadView];
    
    tableView = [[UITableView alloc] initWithFrame:[[self view] bounds] style:UITableViewStyleGrouped];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [[self view] addSubview:tableView];
    
    UIView *backgroundView = [[[UIView alloc] initWithFrame:[tableView bounds]] autorelease];
    [backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setBackgroundView:backgroundView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"More"];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disable-orange"]) {
        [[tableView backgroundView] setBackgroundColor:[UIColor colorWithRed:(242.0f / 255.0f) green:(205.0f / 255.0f) blue:(175.0f / 255.0f) alpha:1.0f]];
    } else {
        [[tableView backgroundView] setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    }
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return 3;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 4;
        case 1: return 2;
        case 2: return 3;
        default: return 0;
    }
}

- (CGFloat)tableView:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    if ([indexPath section] == 0) {
        if ([indexPath row] == 0) {
            [[cell textLabel] setText:@"Best Submissions"];
        } else if ([indexPath row] == 1) {
            [[cell textLabel] setText:@"Active Discussions"];
        } else if ([indexPath row] == 2) {
            [[cell textLabel] setText:@"Classic View"];
        } else if ([indexPath row] == 3) {
            [[cell textLabel] setText:@"Ask HN"];
        }
    } else if ([indexPath section] == 1) {
        if ([indexPath row] == 0) {
            [[cell textLabel] setText:@"Best Comments"];
        } else if ([indexPath row] == 1) {
            [[cell textLabel] setText:@"New Comments"];
        } 
    } else if ([indexPath section] == 2) {
        if ([indexPath row] == 0) {
            [[cell textLabel] setText:@"Hacker News FAQ"];
        } else if ([indexPath row] == 1) {
            [[cell textLabel] setText:@"news:yc homepage"];
        } else if ([indexPath row] == 2) {
            [[cell textLabel] setText:@"@newsyc_"];
        }
    }
    
    return [cell autorelease];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Submissions";
    } else if (section == 1) {
        return @"Comments";
    } else if (section == 2) {
        return @"Other";
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return [NSString stringWithFormat:@"news:yc version %@.\n\nIf you're having issues or have suggestions, feel free to email me: support@newsyc.me\n\nSettings are available in the Settings app.", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    }
    
    return nil;
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HNEntryListIdentifier type = nil;
    NSString *title = nil;
    Class controllerClass = nil;
    
    if ([indexPath section] == 0) {
        if ([indexPath row] == 0) {
            type = kHNEntryListIdentifierBestSubmissions;
            title = @"Best Submissions";
            controllerClass = [SubmissionListController class];
        } else if ([indexPath row] == 1) {
            type = kHNEntryListIdentifierActiveSubmissions;
            title = @"Active";
            controllerClass = [SubmissionListController class];
        } else if ([indexPath row] == 2) {
            type = kHNEntryListIdentifierClassicSubmissions;
            title = @"Classic";
            controllerClass = [SubmissionListController class];
        } else if ([indexPath row] == 3) {
            type = kHNEntryListIdentifierAskSubmissions;
            title = @"Ask HN";
            controllerClass = [SubmissionListController class];
        }
    } else if ([indexPath section] == 1) {
        if ([indexPath row] == 0) {
            type = kHNEntryListIdentifierBestComments;
            title = @"Best Comments";
            controllerClass = [CommentListController class];
        } else if ([indexPath row] == 1) {
            type = kHNEntryListIdentifierNewComments;
            title = @"New Comments";
            controllerClass = [CommentListController class];
        }
    } else if ([indexPath section] == 2) {
        if ([indexPath row] == 0) {
            BrowserController *controller = [[BrowserController alloc] initWithURL:kHNFAQURL];
            [[self navigationController] pushViewController:[controller autorelease] animated:YES];
            return;
        } else if ([indexPath row] == 1) {
            BrowserController *controller = [[BrowserController alloc] initWithURL:[NSURL URLWithString:@"http://newsyc.me/"]];
            [[self navigationController] pushViewController:[controller autorelease] animated:YES];
            return;
        } else if ([indexPath row] == 2) {
            BrowserController *controller = [[BrowserController alloc] initWithURL:[NSURL URLWithString:@"https://twitter.com/newsyc_"]];
            [[self navigationController] pushViewController:[controller autorelease] animated:YES];
            return;
        }
    }
    
    HNEntryList *list = [HNEntryList entryListWithIdentifier:type];
    UIViewController *controller = [[controllerClass alloc] initWithSource:list];
    [controller setTitle:title];
    [[self navigationController] pushViewController:[controller autorelease] animated:YES];
}

AUTOROTATION_FOR_PAD_ONLY

@end
