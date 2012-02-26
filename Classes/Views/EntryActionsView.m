//
//  EntryActionsView.m
//  newsyc
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HNKit.h"

#import "EntryActionsView.h"

@interface EntryActionsView ()

- (UIImage *)imageForItem:(EntryActionsViewItem)item;
- (UIBarButtonItem *)createBarButtonItemForItem:(EntryActionsViewItem)item;
- (void)updateItems;

@end

@implementation EntryActionsView
@synthesize entry, delegate;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self updateItems];
    }
    
    return self;
}

- (void)dealloc {
    [entry release];
    [super dealloc];
}

- (void)upvoteTapped:(UIButton *)button {
    [delegate entryActionsView:self didSelectItem:kEntryActionsViewItemUpvote];
}

- (void)replyTapped:(UIButton *)button {
    [delegate entryActionsView:self didSelectItem:kEntryActionsViewItemReply];
}

- (void)flagTapped:(UIButton *)button {
    [delegate entryActionsView:self didSelectItem:kEntryActionsViewItemFlag];
}

- (void)downvoteTapped:(UIButton *)button {
    [delegate entryActionsView:self didSelectItem:kEntryActionsViewItemDownvote];
}

- (void)actionsTapped:(UIButton *)button {
    [delegate entryActionsView:self didSelectItem:kEntryActionsViewItemActions];
}

- (void)updateItems {
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *replyItem = [self createBarButtonItemForItem:kEntryActionsViewItemReply];
    UIBarButtonItem *upvoteItem = [self createBarButtonItemForItem:kEntryActionsViewItemUpvote];
    UIBarButtonItem *flagItem = [self createBarButtonItemForItem:kEntryActionsViewItemFlag];
    UIBarButtonItem *downvoteItem = [self createBarButtonItemForItem:kEntryActionsViewItemDownvote];
    UIBarButtonItem *actionsItem = [self createBarButtonItemForItem:kEntryActionsViewItemActions];
    
    [self setItems:[NSArray arrayWithObjects:replyItem, flexibleSpace, upvoteItem, flexibleSpace, flagItem, flexibleSpace, downvoteItem, flexibleSpace, actionsItem, nil]];
     
    [flexibleSpace release];
}

// XXX: this is just one giant hack; we should store references to these objects
- (UIBarButtonItem *)barButtonItemForItem:(EntryActionsViewItem)item {
    NSArray *items = [self items];
    
    switch (item) {
        case kEntryActionsViewItemReply:
            return [items objectAtIndex:0];
        case kEntryActionsViewItemUpvote:
            return [items objectAtIndex:3];
        case kEntryActionsViewItemFlag:
            return [items objectAtIndex:5];
        case kEntryActionsViewItemDownvote:
            return [items objectAtIndex:7];
        case kEntryActionsViewItemActions:
            return [items objectAtIndex:9];
        default:
            return nil;
    }
}

- (void)setEnabled:(BOOL)enabled forItem:(EntryActionsViewItem)item {
    switch (item) {
        case kEntryActionsViewItemReply:
            replyDisabled = !enabled;
            break;
        case kEntryActionsViewItemUpvote:
            upvoteDisabled = !enabled;
            break;
        case kEntryActionsViewItemFlag:
            flagDisabled = !enabled;
            break;
        case kEntryActionsViewItemDownvote:
            downvoteDisabled = !enabled;
            break;
        case kEntryActionsViewItemActions:
            actionsDisabled = !enabled;
            break;
        default:
            break;
    }
    
    [self updateItems];
}

- (BOOL)itemIsEnabled:(EntryActionsViewItem)item {
    switch (item) {
        case kEntryActionsViewItemReply:
            return !replyDisabled;
        case kEntryActionsViewItemUpvote:
            return !upvoteDisabled;
        case kEntryActionsViewItemFlag:
            return !flagDisabled;
        case kEntryActionsViewItemDownvote:
            return !downvoteDisabled;
        case kEntryActionsViewItemActions:
            return !actionsDisabled;
        default:
            return YES;
    }
}

- (UIImage *)imageForItem:(EntryActionsViewItem)item {
    switch (item) {
        case kEntryActionsViewItemReply:
            return [UIImage imageNamed:@"reply.png"];
        case kEntryActionsViewItemUpvote:
            return [UIImage imageNamed:@"upvote.png"];
        case kEntryActionsViewItemFlag:
            return [UIImage imageNamed:@"flag.png"];
        case kEntryActionsViewItemDownvote:
            return [UIImage imageNamed:@"downvote.png"];
        case kEntryActionsViewItemActions:
            return [UIImage imageNamed:@"action.png"];
        default:
            return nil;
    }
}

- (UIBarButtonItem *)createBarButtonItemForItem:(EntryActionsViewItem)item {
    UIBarButtonItem *barButtonItem = nil;
    UIImage *itemImage = [self imageForItem:item];
    
    if ([self itemIsLoading:item]) {
        barButtonItem = [[ActivityIndicatorItem alloc] initWithSize:[itemImage size]];
    } else {
        switch (item) {
            case kEntryActionsViewItemReply:
                barButtonItem = [[UIBarButtonItem alloc] initWithImage:itemImage style:UIBarButtonItemStylePlain target:self action:@selector(replyTapped:)];
                break;
            case kEntryActionsViewItemUpvote:
                barButtonItem = [[UIBarButtonItem alloc] initWithImage:itemImage style:UIBarButtonItemStylePlain target:self action:@selector(upvoteTapped:)];
                break;
            case kEntryActionsViewItemFlag:
                barButtonItem = [[UIBarButtonItem alloc] initWithImage:itemImage style:UIBarButtonItemStylePlain target:self action:@selector(flagTapped:)];
                break;
            case kEntryActionsViewItemDownvote:
                barButtonItem = [[UIBarButtonItem alloc] initWithImage:itemImage style:UIBarButtonItemStylePlain target:self action:@selector(downvoteTapped:)];
                break;
            case kEntryActionsViewItemActions:
                barButtonItem = [[UIBarButtonItem alloc] initWithImage:itemImage style:UIBarButtonItemStylePlain target:self action:@selector(actionsTapped:)];
                break;
            default:
                break;
        }
    }

    [barButtonItem setEnabled:[self itemIsEnabled:item]];
    return [barButtonItem autorelease];
}     

- (void)beginLoadingItem:(EntryActionsViewItem)item {
    switch (item) {
        case kEntryActionsViewItemReply:
            replyLoading += 1;
            break;
        case kEntryActionsViewItemUpvote:
            upvoteLoading += 1;
            break;
        case kEntryActionsViewItemFlag:
            flagLoading += 1;
            break;
        case kEntryActionsViewItemDownvote:
            downvoteLoading += 1;
            break;
        case kEntryActionsViewItemActions:
            actionsLoading += 1;
            break;
        default:
            break;
    }
    
    [self updateItems];
}

- (void)stopLoadingItem:(EntryActionsViewItem)item {
    switch (item) {
        case kEntryActionsViewItemReply:
            replyLoading -= 1;
            break;
        case kEntryActionsViewItemUpvote:
            upvoteLoading -= 1;
            break;
        case kEntryActionsViewItemFlag:
            flagLoading -= 1;
            break;
        case kEntryActionsViewItemDownvote:
            downvoteLoading -= 1;
            break;
        case kEntryActionsViewItemActions:
            actionsLoading -= 1;
            break;
        default:
            break;
    }
    
    [self updateItems];
}

- (BOOL)itemIsLoading:(EntryActionsViewItem)item {
    switch (item) {
        case kEntryActionsViewItemReply:
            return replyLoading > 0;
        case kEntryActionsViewItemUpvote:
            return upvoteLoading > 0;
        case kEntryActionsViewItemFlag:
            return flagLoading > 0;
        case kEntryActionsViewItemDownvote:
            return downvoteLoading > 0;
        case kEntryActionsViewItemActions:
            return actionsLoading > 0;
        default:
            return NO;
    }
}

- (void)setEntry:(HNEntry *)entry_ {
    [entry autorelease];
    entry = [entry_ retain];
    
    [self updateItems];
}

@end
