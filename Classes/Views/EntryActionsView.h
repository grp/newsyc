//
//  EntryActionsView.h
//  newsyc
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

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
    
    UIBarButtonItem *upvoteItem;
    UIBarButtonItem *replyItem;
    UIBarButtonItem *flagItem;
    UIBarButtonItem *downvoteItem;
    UIBarButtonItem *submitterItem;
}

@property (nonatomic, retain) HNEntry *entry;
@property (nonatomic, assign) id<EntryActionsViewDelegate> delegate;

@end

@protocol EntryActionsViewDelegate<NSObject>

- (void)entryActionsView:(EntryActionsView *)eav didSelectItem:(EntryActionsViewItem)item;

@end
