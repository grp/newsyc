//
//  ProfileController.m
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"

#import "ProfileController.h"
#import "ProfileHeaderView.h"

#import "SubmissionListController.h"
#import "CommentListController.h"

#import "NSString+Tags.h"

@implementation ProfileController

- (void)dealloc {
    [tableView release];
    [header release];
    
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
    
    header = [[ProfileHeaderView alloc] initWithFrame:CGRectMake(0, 0, [[self view] bounds].size.width, 65.0f)];
    [header setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
    [tableView setTableHeaderView:header];
    
    [[self view] bringSubviewToFront:statusView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Profile"];
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

- (void)finishedLoading {
    [header setTitle:[(HNUser *) source identifier]];
    [header setSubtitle:[NSString stringWithFormat:@"User for %@.", [(HNUser *) source created]]];
    [tableView reloadData];
}

- (BOOL)hasAbout {
    return [(HNUser *) source about] != nil && [[(HNUser *) source about] length] > 0;
}

- (NSString *)aboutText {
    NSString *about = [(HNUser *) source about];
    about = [about stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n\n"];
    about = [about stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    about = [about stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    about = [about stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    about = [about stringByRemovingHTMLTags];
    return about;
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

- (CGFloat)tableView:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] == 0 && [indexPath row] == 0 && [self hasAbout]) {
		NSString *text = [self aboutText];
		CGSize constraint = CGSizeMake([[self view] bounds].size.width - 40.0f, 4000.0f);
		CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        size.height += 20.0f;
		if (size.height >= 64.0f) return size.height;
		else return 64.0;
	}
    
	return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if ([indexPath section] == 0) {
        if ([indexPath row] == 0 && [self hasAbout]) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            [[cell textLabel] setText:[self aboutText]];
            [[cell textLabel] setFont:[UIFont systemFontOfSize:16.0]];
            [[cell textLabel] setNumberOfLines:0];
        } else {
            int row = [indexPath row] - ([self hasAbout] ? 1 : 0);
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
            
            if (row == 0) {
                [[cell textLabel] setText:@"karma"];
                [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%d", [(HNUser *) source karma]]];
            } else if (row == 1) {
                [[cell textLabel] setText:@"average"];
                [[cell detailTextLabel] setText:[[NSNumber numberWithFloat:[(HNUser *) source average]] stringValue]];
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
    return [cell autorelease];
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
        
        HNEntryList *list = [HNEntryList entryListWithIdentifier:type user:(HNUser *) source];
        
        EntryListController *controller = [[controllerClass alloc] initWithSource:list];
        [controller setTitle:title];
        [[self navigationController] pushViewController:[controller autorelease] animated:YES];
    }
}

AUTOROTATION_FOR_PAD_ONLY

@end
