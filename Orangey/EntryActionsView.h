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
@interface EntryActionsView : UIView {
    HNEntry *entry;
    UIButton *submitterButton;
    UIView *toolbarContainer;
    id<EntryActionsViewDelegate> delegate;
}

@property (nonatomic, retain) HNEntry *entry;
@property (nonatomic, assign) id<EntryActionsViewDelegate> delegate;

@end

@protocol EntryActionsViewDelegate<NSObject>

- (void)entryActionsView:(EntryActionsView *)eav didSelectItem:(EntryActionsViewItem)item;

@end
