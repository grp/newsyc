//
//  EntryActionsView.h
//  newsyc
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "ActivityIndicatorItem.h"

// XXX: this class should support replacing an item with a spinner
// while something is loading (e.g. a vote is being submitted)

typedef enum {
    kEntryActionsViewItemUpvote,
    kEntryActionsViewItemReply,
    kEntryActionsViewItemFlag,
    kEntryActionsViewItemDownvote,
    kEntryActionsViewItemSubmitter
} EntryActionsViewItem;

@protocol EntryActionsViewDelegate;
@class HNEntry;
@interface EntryActionsView : UIToolbar {
    HNEntry *entry;
    id<EntryActionsViewDelegate> delegate;
    
    int upvoteLoading;
    BOOL upvoteDisabled;
    int replyLoading;
    BOOL replyDisabled;
    int flagLoading;
    BOOL flagDisabled;
    int downvoteLoading;
    BOOL downvoteDisabled;
    int submitterLoading;
    BOOL submitterDisabled;
}

@property (nonatomic, retain) HNEntry *entry;
@property (nonatomic, assign) id<EntryActionsViewDelegate> delegate;

- (void)setEnabled:(BOOL)enabled forItem:(EntryActionsViewItem)item;
- (BOOL)itemIsEnabled:(EntryActionsViewItem)item;
- (void)beginLoadingItem:(EntryActionsViewItem)item;
- (void)stopLoadingItem:(EntryActionsViewItem)item;
- (BOOL)itemIsLoading:(EntryActionsViewItem)item;
- (UIBarButtonItem *)barButtonItemForItem:(EntryActionsViewItem)item;

@end

@protocol EntryActionsViewDelegate<NSObject>

- (void)entryActionsView:(EntryActionsView *)eav didSelectItem:(EntryActionsViewItem)item;

@end
