//
//  CommentTableCell.h
//  newsyc
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "TableViewCell.h"
#import "EntryActionsView.h"

@protocol CommentTableCellDelegate;

@class HNEntry;
@interface CommentTableCell : TableViewCell {
    HNEntry *comment;
    int indentationLevel;
    
    CGRect bodyrect;
    NSSet *highlightedRects;
    
    __weak id<CommentTableCellDelegate> delegate;
    
    BOOL expanded;
    EntryActionsView *toolbarView;

    UITapGestureRecognizer *tapRecognizer;
    UITapGestureRecognizer *doubleTapRecognizer;
    UILongPressGestureRecognizer *linkLongPressRecognizer;

    BOOL navigationCancelled;
}

@property (nonatomic, assign) id<CommentTableCellDelegate> delegate;
@property (nonatomic, retain) HNEntry *comment;
@property (nonatomic, assign) int indentationLevel;
@property (nonatomic, assign) BOOL expanded;

+ (CGFloat)heightForEntry:(HNEntry *)entry withWidth:(CGFloat)width expanded:(BOOL)expanded indentationLevel:(int)indentationLevel;

- (id)initWithReuseIdentifier:(NSString *)identifier;

@end

@protocol CommentTableCellDelegate <EntryActionsViewDelegate>
@optional

- (void)commentTableCellTapped:(CommentTableCell *)cell;
- (void)commentTableCellDoubleTapped:(CommentTableCell *)cell;
- (void)commentTableCell:(CommentTableCell *)cell selectedURL:(NSURL *)url;

@end

