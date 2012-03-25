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
#import "UIImage+Colorize.h"

@interface EntryActionsView ()

- (UIImage *)imageForItem:(EntryActionsViewItem)item;
- (BarButtonItem *)createBarButtonItemForItem:(EntryActionsViewItem)item;
- (void)updateItems;

@end

@implementation EntryActionsView
@synthesize entry, delegate, style;

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
    BarButtonItem *flexibleSpace = [[BarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    BarButtonItem *replyItem = [self createBarButtonItemForItem:kEntryActionsViewItemReply];
    BarButtonItem *upvoteItem = [self createBarButtonItemForItem:kEntryActionsViewItemUpvote];
    BarButtonItem *flagItem = [self createBarButtonItemForItem:kEntryActionsViewItemFlag];
    BarButtonItem *downvoteItem = [self createBarButtonItemForItem:kEntryActionsViewItemDownvote];
    BarButtonItem *actionsItem = [self createBarButtonItemForItem:kEntryActionsViewItemActions];
    
    [self setItems:[NSArray arrayWithObjects:replyItem, flexibleSpace, upvoteItem, flexibleSpace, flagItem, flexibleSpace, downvoteItem, flexibleSpace, actionsItem, nil]];
     
    [flexibleSpace release];
}

- (void)setStyle:(EntryActionsViewStyle)style_ {
    style = style_;
    
    if (style == kEntryActionsViewStyleDefault) {
        [self setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [self setTintColor:nil];
    } else if (style == kEntryActionsViewStyleOrange) {
        [self setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [self setTintColor:[UIColor colorWithRed:1.0f green:0.4f blue:0.0f alpha:1.0f]];
    } else if (style == kEntryActionsViewStyleLight) {
        UIImage *backgroundImage = [[UIImage imageNamed:@"toolbar-expanded.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
        [self setBackgroundImage:backgroundImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [self setTintColor:[UIColor whiteColor]];
    } else if (style == kEntryActionsViewStyleTransparentLight) {
        UIImage *clearImage = [UIImage imageNamed:@"clear.png"];
        [self setBackgroundImage:clearImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [self setTintColor:[UIColor blackColor]];
    } else if (style == kEntryActionsViewStyleTransparentDark) {
        UIImage *clearImage = [UIImage imageNamed:@"clear.png"];
        [self setBackgroundImage:clearImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [self setTintColor:nil];
    }
}

// XXX: this is just one giant hack; we should store references to these objects
- (BarButtonItem *)barButtonItemForItem:(EntryActionsViewItem)item {
    NSArray *items = [self items];
    
    switch (item) {
        case kEntryActionsViewItemReply:
            return [items objectAtIndex:0];
        case kEntryActionsViewItemUpvote:
            return [items objectAtIndex:2];
        case kEntryActionsViewItemFlag:
            return [items objectAtIndex:4];
        case kEntryActionsViewItemDownvote:
            return [items objectAtIndex:6];
        case kEntryActionsViewItemActions:
            return [items objectAtIndex:8];
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
    
    [[self barButtonItemForItem:item] setEnabled:enabled];
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

- (BarButtonItem *)barButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)action {
    return [[[BarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:action] autorelease];
}

- (BarButtonItem *)createBarButtonItemForItem:(EntryActionsViewItem)item {
    BarButtonItem *barButtonItem = nil;
    UIImage *itemImage = [self imageForItem:item];
    
    if ([self itemIsLoading:item]) {
        barButtonItem = [[[ActivityIndicatorItem alloc] initWithSize:[itemImage size]] autorelease];
    } else {
        SEL action = NULL;

        switch (item) {
            case kEntryActionsViewItemReply:
                action = @selector(replyTapped:);
                break;
            case kEntryActionsViewItemUpvote:
                action = @selector(upvoteTapped:);
                break;
            case kEntryActionsViewItemFlag:
                action = @selector(flagTapped:);
                break;
            case kEntryActionsViewItemDownvote:
                action = @selector(downvoteTapped:);
                break;
            case kEntryActionsViewItemActions:
                action = @selector(actionsTapped:);
                break;
            default:
                break;
        }
        
        barButtonItem = [self barButtonItemWithImage:itemImage target:self action:action];
    }

    [barButtonItem setEnabled:[self itemIsEnabled:item]];
    return barButtonItem;
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
}

@end
