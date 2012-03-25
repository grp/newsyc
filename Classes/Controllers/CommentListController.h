//
//  CommentListController.h
//  newsyc
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "EntryListController.h"
#import "ComposeController.h"
#import "EntryActionsView.h"
#import "DetailsHeaderView.h"
#import "LoginController.h"
#import "CommentTableCell.h"
#import "BarButtonItem.h"

@interface CommentListController : EntryListController <EntryActionsViewDelegate, DetailsHeaderViewDelegate, LoginControllerDelegate, ComposeControllerDelegate, CommentTableCellDelegate> {
    UIView *detailsHeaderContainer;
    DetailsHeaderView *detailsHeaderView;
    EntryActionsView *entryActionsView;
    BarButtonItem *entryActionsViewItem;
    UIView *containerContainer;
    CGFloat suggestedHeaderHeight;

    void (^savedAction)();
    void (^savedCompletion)(int);
    BOOL shouldCompleteOnAppear;
    
    HNEntry *expandedEntry;
    CommentTableCell *expandedCell;
}

@end
