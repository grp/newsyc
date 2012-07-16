//
//  EntryActionsView.h
//  newsyc
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "ActivityIndicatorItem.h"
#import "BarButtonItem.h"

typedef enum {
    kEntryActionsViewItemUpvote,
    kEntryActionsViewItemReply,
    kEntryActionsViewItemFlag,
    kEntryActionsViewItemDownvote,
    kEntryActionsViewItemActions
} EntryActionsViewItem;

typedef enum {
    kEntryActionsViewStyleDefault,
    kEntryActionsViewStyleOrange,
    kEntryActionsViewStyleTransparentLight,
    kEntryActionsViewStyleTransparentDark,
    kEntryActionsViewStyleLight
} EntryActionsViewStyle;

@protocol EntryActionsViewDelegate;
@class HNEntry;
@interface EntryActionsView : UIToolbar {
    HNEntry *entry;
    __weak id<EntryActionsViewDelegate> delegate;
    
    int upvoteLoading;
    BOOL upvoteDisabled;
    int replyLoading;
    BOOL replyDisabled;
    int flagLoading;
    BOOL flagDisabled;
    int downvoteLoading;
    BOOL downvoteDisabled;
    int actionsLoading;
    BOOL actionsDisabled;
    
    EntryActionsViewStyle style;
}

@property (nonatomic, retain) HNEntry *entry;
@property (nonatomic, assign) id<EntryActionsViewDelegate> delegate;
@property (nonatomic, assign) EntryActionsViewStyle style;

- (void)setEnabled:(BOOL)enabled forItem:(EntryActionsViewItem)item;
- (BOOL)itemIsEnabled:(EntryActionsViewItem)item;
- (void)beginLoadingItem:(EntryActionsViewItem)item;
- (void)stopLoadingItem:(EntryActionsViewItem)item;
- (BOOL)itemIsLoading:(EntryActionsViewItem)item;
- (BarButtonItem *)barButtonItemForItem:(EntryActionsViewItem)item;

@end

@protocol EntryActionsViewDelegate<NSObject>

- (void)entryActionsView:(EntryActionsView *)eav didSelectItem:(EntryActionsViewItem)item;

@end
