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
}

@property (nonatomic, retain) HNEntry *comment;

+ (CGFloat)heightForEntry:(HNEntry *)entry withWidth:(CGFloat)width;
- (id)initWithReuseIdentifier:(NSString *)identifier;

@end
