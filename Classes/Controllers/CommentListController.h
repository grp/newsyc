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

@interface CommentListController : EntryListController <EntryActionsViewDelegate, DetailsHeaderViewDelegate, LoginControllerDelegate, ComposeControllerDelegate> {
    UIView *detailsHeaderContainer;
    DetailsHeaderView *detailsHeaderView;
    EntryActionsView *entryActionsView;
    UIView *containerContainer;
    CGFloat suggestedHeaderHeight;
    CGFloat maximumHeaderHeight;
        
    EntryActionsViewItem savedItem;
    BOOL shouldCompleteOnAppear;

    int goToParentIndex;
    int goToSubmissionIndex;
}

@end
