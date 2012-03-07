//
//  CommentTableCell.h
//  newsyc
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "ABTableViewCell.h"
#import "EntryActionsView.h"

@protocol CommentTableCellDelegate;

@class HNEntry;
@interface CommentTableCell : ABTableViewCell <UIActionSheetDelegate> {
    HNEntry *comment;
    int indentationLevel;
    
    CGRect bodyRect;
    NSSet *highlightedRects;
    
    id<CommentTableCellDelegate> delegate;
    
    BOOL expanded;
    EntryActionsView *toolbarView;
}

@property (nonatomic, assign) id<CommentTableCellDelegate> delegate;
@property (nonatomic, retain) HNEntry *comment;
@property (nonatomic, assign) int indentationLevel;
@property (nonatomic, assign) BOOL expanded;

+ (CGFloat)heightForEntry:(HNEntry *)entry withWidth:(CGFloat)width expanded:(BOOL)expanded indentationLevel:(int)indentationLevel;

- (id)initWithReuseIdentifier:(NSString *)identifier;

@end

@protocol CommentTableCellDelegate<EntryActionsViewDelegate>
@optional

- (void)commentTableCellTapped:(CommentTableCell *)cell;
- (void)commentTableCellDoubleTapped:(CommentTableCell *)cell;
- (void)commentTableCell:(CommentTableCell *)cell selectedURL:(NSURL *)url;

@end

