//
//  CommentListController.h
//  newsyc
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "EntryListController.h"
#import "EntryActionsView.h"
#import "DetailsHeaderView.h"
#import "LoginController.h"

@class HeaderContainerView;
@interface CommentListController : EntryListController <EntryActionsViewDelegate, DetailsHeaderViewDelegate, LoginControllerDelegate> {
    HeaderContainerView *headerContainerView;
    EntryActionsView *entryActionsView;
    UIView *containerContainer;
    CGFloat suggestedHeaderHeight;
    CGFloat maximumHeaderHeight;
    
    EntryActionsViewItem savedItem;
    BOOL shouldCompleteOnAppear;
}

@end
