//
//  ProfileController.m
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import <HNKit/HNKit.h>

#import "NSString+Tags.h"

#import "ProfileController.h"
#import "ProfileHeaderView.h"
#import "BodyTextView.h"

#import "SubmissionListController.h"
#import "CommentListController.h"
#import "BrowserController.h"

#import "AppDelegate.h"

@implementation ProfileController


- (void)loadView {
    [super loadView];
    
    tableView = [[OrangeTableView alloc] initWithFrame:[[self view] bounds]];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [[self view] addSubview:tableView];

    header = [[ProfileHeaderView alloc] initWithFrame:CGRectMake(0, 0, [[self view] bounds].size.width, [ProfileHeaderView defaultHeight])];
    [header setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
    [tableView setTableHeaderView:header];

    [[self view] bringSubviewToFront:statusView];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"Profile"];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self setModalPresentationStyle:UIModalPresentationFormSheet];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    tableView = nil;
    header = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [tableView setOrange:![[NSUserDefaults standardUserDefaults] boolForKey:@"disable-orange"]];
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [header setPadding:([self groupedTablePadding] + 10.0f)];

    /*if ([self respondsToSelector:@selector(topLayoutGuide)] && [self respondsToSelector:@selector(bottomLayoutGuide)]) {
        UIEdgeInsets insets = UIEdgeInsetsMake([[self topLayoutGuide] length], 0, [[self bottomLayoutGuide] length], 0);
        [tableView setScrollIndicatorInsets:insets];
        [tableView setContentInset:insets];
    }*/
}

- (void)finishedLoading {
    [header setTitle:[(HNUser *) source identifier]];
    [header setSubtitle:[NSString stringWithFormat:@"User for %@.", [(HNUser *) source created]]];
    [tableView reloadData];
}

- (BOOL)hasAbout {
    return [[(HNUser *) source about] length] != 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return 2;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return [self hasAbout] ? 3 : 2;
        case 1: return 2;
        default: return 0;
    }
}

- (CGFloat)groupedTablePadding {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return 10.0f;
    }

    if ([UITableViewCell instancesRespondToSelector:@selector(separatorInset)]) {
        return 10.0;
    }

    if ([tableView bounds].size.width <= 320.0f) {
        return 10.0f;
    } else {
        return 30.0f;
    }
}

- (UIEdgeInsets)aboutPadding {
    UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);

    if ([UITableViewCell instancesRespondToSelector:@selector(separatorInset)]) {
        // We don't have a table cell yet, so guess at the padding.
        padding.left += 5.0;
    }

    return padding;
}

- (CGSize)aboutSize {
    HNObjectBodyRenderer *renderer = [(HNUser *)source renderer];

    CGSize size;
    size.width = [tableView bounds].size.width - ([self groupedTablePadding] * 2) - ([self aboutPadding].left + [self aboutPadding].right);
    size.height = [renderer sizeForWidth:size.width].height;
    
    return size;
}

- (CGFloat)tableView:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] == 0 && [indexPath row] == 0 && [self hasAbout]) {
        return [self aboutSize].height + [self aboutPadding].top + [self aboutPadding].bottom;
	}
    
	return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if ([indexPath section] == 0) {
        if ([indexPath row] == 0 && [self hasAbout]) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            BodyTextView *textView = [[BodyTextView alloc] init];
            [textView setRenderer:[(HNUser *)source renderer]];
            [textView setDelegate:self];
            
            CGSize aboutSize = [self aboutSize];
            [textView setFrame:CGRectMake([self aboutPadding].left, [self aboutPadding].top, aboutSize.width, aboutSize.height)];
            
            [[cell contentView] addSubview:textView];
        } else {
            NSInteger row = [indexPath row] - ([self hasAbout] ? 1 : 0);
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
            
            if (row == 0) {
                [[cell textLabel] setText:@"karma"];
                [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%d", [(HNUser *) source karma]]];
            } else if (row == 1) {
                [[cell textLabel] setText:@"average"];
                [[cell detailTextLabel] setText:[@([(HNUser *) source average]) stringValue]];
            }
        }
    } else if ([indexPath section] == 1) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        if ([indexPath row] == 0) {
            [[cell textLabel] setText:@"Submissions"];
        } else if ([indexPath row] == 1) {
            [[cell textLabel] setText:@"Comments"];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    } else {
        HNEntryListIdentifier type = nil;
        NSString *title = nil;
        Class controllerClass = nil;
        
        if ([indexPath row] == 0) {
            type = kHNEntryListIdentifierUserSubmissions;
            title = @"Submissions";
            controllerClass = [SubmissionListController class];
        } else if ([indexPath row] == 1) {
            type = kHNEntryListIdentifierUserComments;
            title = @"Comments";
            controllerClass = [CommentListController class];
        }
        
        HNEntryList *list = [HNEntryList session:[source session] entryListWithIdentifier:type user:(HNUser *) source];
        
        UIViewController *controller = [[controllerClass alloc] initWithSource:list];
        [controller setTitle:title];
        [[self navigation] pushController:controller animated:YES];
    }
}

- (NSString *)sourceTitle {
    return [(HNUser *) source identifier];
}

- (void)bodyTextView:(BodyTextView *)header selectedURL:(NSURL *)url {
    BrowserController *controller = [[BrowserController alloc] initWithURL:url];
    [[self navigation] pushController:controller animated:YES];
}

AUTOROTATION_FOR_PAD_ONLY

@end
