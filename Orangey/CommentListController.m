//
//  CommentListController.m
//  Orangey
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HNKit.h"

#import "CommentListController.h"
#import "CommentTableCell.h"
#import "SlidingHeaderView.h"
#import "HeaderContainerView.h"
#import "DetailsHeaderView.h"
#import "SubmissionDetailsHeaderView.h"
#import "CommentDetailsHeaderView.h"
#import "EntryActionsView.h"
#import "ProfileController.h"
#import "BrowserController.h"

@implementation CommentListController

- (void)detailsHeaderView:(DetailsHeaderView *)header selectedURL:(NSURL *)url {
    BrowserController *controller = [[BrowserController alloc] initWithURL:url];
    [[self navigationController] pushViewController:[controller autorelease] animated:YES];
}

- (void)entryActionsView:(EntryActionsView *)eav didSelectItem:(EntryActionsViewItem)item {
    if (item == kEntryActionsViewItemSubmitter) {
        ProfileController *controller = [[ProfileController alloc] initWithSource:[(HNEntry *) source submitter]];
        [controller setTitle:@"Profile"];
        [[self navigationController] pushViewController:[controller autorelease] animated:YES];
    } // XXX: handle others
}

- (void)dealloc {
    [containerContainer release];
    [headerContainerView release];
    [super dealloc];
}

- (void)finishedLoading {
    if ([(HNEntry *) source submitter] != nil) {
        headerContainerView = [[HeaderContainerView alloc] initWithEntry:(HNEntry *) source widthWidth:[[self view] bounds].size.width];
        [headerContainerView setClipsToBounds:YES];
        [headerContainerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
        [[headerContainerView entryActionsView] setDelegate:self];
        [[headerContainerView detailsHeaderView] setDelegate:self];
        
        UIView *shadow = [[UIView alloc] initWithFrame:CGRectMake(-50.0f, [headerContainerView bounds].size.height, [[self view] bounds].size.width + 100.0f, 1.0f)];
        CALayer *layer = [shadow layer];
        [layer setShadowOffset:CGSizeMake(0, -2.0f)];
        [layer setShadowRadius:5.0f];
        [layer setShadowColor:[[UIColor blackColor] CGColor]];
        [layer setShadowOpacity:1.0f];
        [shadow setBackgroundColor:[UIColor grayColor]];
        [shadow setClipsToBounds:NO];
        
        containerContainer = [[UIView alloc] initWithFrame:[headerContainerView bounds]];
        [containerContainer setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [containerContainer setBackgroundColor:[UIColor clearColor]];
        [containerContainer addSubview:headerContainerView];
        [containerContainer addSubview:[shadow autorelease]];
        [containerContainer setClipsToBounds:NO];
        [tableView setTableHeaderView:containerContainer];
        
        suggestedHeaderHeight = [headerContainerView bounds].size.height;
        maximumHeaderHeight = [tableView bounds].size.height - 44.0f;
    }

    [super finishedLoading];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = [scrollView contentOffset].y;
    if (suggestedHeaderHeight < maximumHeaderHeight || (offset > suggestedHeaderHeight - maximumHeaderHeight || offset <= 0)) {
        CGRect frame = [headerContainerView frame];
        if (suggestedHeaderHeight - maximumHeaderHeight > 0 && offset > 0) offset -= suggestedHeaderHeight - maximumHeaderHeight;
        frame.origin.y = offset;
        frame.size.height = suggestedHeaderHeight - offset;
        [headerContainerView setFrame:frame];
    }
}

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Re-apply header if reloading after a view unload.
    if (containerContainer != nil) [tableView setTableHeaderView:containerContainer];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return [source isLoaded] ? 1 : 0;
}

- (HNEntry *)entryAtIndexPath:(NSIndexPath *)indexPath {
    return [[(HNEntry *) source entries] objectAtIndex:[indexPath row]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[(HNEntry *) source entries] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HNEntry *entry = [self entryAtIndexPath:indexPath];
    return [CommentTableCell heightForEntry:entry withWidth:[[self view] bounds].size.width];
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentTableCell *cell = (CommentTableCell *) [tableView dequeueReusableCellWithIdentifier:@"comment"];
    if (cell == nil) cell = [[[CommentTableCell alloc] initWithReuseIdentifier:@"comment"] autorelease];
    
    HNEntry *entry = [self entryAtIndexPath:indexPath];
    [cell setComment:entry];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HNEntry *entry = [self entryAtIndexPath:indexPath];
    
    CommentListController *controller = [[CommentListController alloc] initWithSource:(HNObject *) entry];
    [controller setTitle:@"Comments"];
    [[self navigationController] pushViewController:[controller autorelease] animated:YES];
}

@end
