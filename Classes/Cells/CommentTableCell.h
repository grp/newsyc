//
//  CommentTableCell.h
//  newsyc
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "ABTableViewCell.h"

@class HNEntry;
@interface CommentTableCell : ABTableViewCell {
    HNEntry *comment;
    int indentationLevel;
    BOOL showReplies;
}

@property (nonatomic, retain) HNEntry *comment;
@property (nonatomic, assign) int indentationLevel;
@property (nonatomic, assign) BOOL showReplies;

+ (CGFloat)heightForEntry:(HNEntry *)entry withWidth:(CGFloat)width showReplies:(BOOL)replies;
+ (CGFloat)heightForEntry:(HNEntry *)entry withWidth:(CGFloat)width showReplies:(BOOL)replies indentationLevel:(int)indentationLevel;

- (id)initWithReuseIdentifier:(NSString *)identifier;

@end
