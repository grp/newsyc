//
//  LoadMoreCell.h
//  newsyc
//
//  Created by Grant Paul on 3/25/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "TableViewCell.h"
#import "LoadMoreButton.h"

@interface LoadMoreCell : TableViewCell {
    LoadMoreButton *button;
}

@property (nonatomic, readonly, retain) LoadMoreButton *button;

@end
