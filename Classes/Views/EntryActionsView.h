//
//  EntryActionsView.h
//  Orangey
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
