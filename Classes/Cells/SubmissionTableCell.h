//
//  SubmissionTableCell.h
//  newsyc
//
//  Created by Grant Paul on 3/5/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "TableViewCell.h"

@class HNEntry;
@interface SubmissionTableCell : TableViewCell {
    HNEntry *submission;
}

@property (nonatomic, retain) HNEntry *submission;

+ (CGFloat)heightForEntry:(HNEntry *)entry withWidth:(CGFloat)width;
- (id)initWithReuseIdentifier:(NSString *)identifier;

@end
