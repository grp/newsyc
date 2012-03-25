// Copyright (c) 2008 Loren Brichter
// 
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
//  ABTableViewCell.m
//
//  Created by Loren Brichter
//  Copyright 2008 Loren Brichter. All rights reserved.
//

#import "TableViewCell.h"

@interface TableViewCellView : UIView {
    __weak TableViewCell *cell;
}
@end

@implementation TableViewCellView

- (id)initWithCell:(TableViewCell *)cell_ {
    if ((self = [super initWithFrame:CGRectZero])) {
        cell = cell_;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
	[cell drawContentView:rect];
}

@end

@implementation TableViewCell
@synthesize showsDivider;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		contentView = [[TableViewCellView alloc] initWithCell:self];
		[contentView setOpaque:YES];
		[self addSubview:contentView];
		[contentView release];
        
        [self setShowsDivider:YES];
    }
    return self;
}

- (void)setShowsDivider:(BOOL)shows {
    showsDivider = shows;
    
    // Update content view frame.
    [self setFrame:[self frame]];
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
    
	CGRect bounds = [self bounds];
	if (showsDivider) bounds.size.height -= 1; // leave room for the seperator line
	[contentView setFrame:bounds];
}

- (void)setNeedsDisplay {
	[super setNeedsDisplay];
	[contentView setNeedsDisplay];
}

- (void)drawContentView:(CGRect)rect {
	// subclasses should implement this
}

@end
