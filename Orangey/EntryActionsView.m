//
//  EntryActionsView.m
//  Orangey
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HNKit.h"

#import "EntryActionsView.h"

@implementation EntryActionsView
@synthesize entry, delegate;

- (void)submitterButtonTapped:(UIButton *)button {
    [delegate entryActionsView:self didSelectItem:kEntryActionsViewItemSubmitter];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setClipsToBounds:YES];
        
        submitterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        CGFloat buttonWidth = [self bounds].size.width * 0.385f;
        [submitterButton setFrame:CGRectMake([self bounds].size.width - buttonWidth - 15.0f, -2.0f, buttonWidth + 30.0f, [self bounds].size.height + 4.0f)];
        [self addSubview:submitterButton];
        [submitterButton addTarget:self action:@selector(submitterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        toolbarContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self bounds].size.width - buttonWidth, [self bounds].size.height)];
        [toolbarContainer setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:toolbarContainer];
    }
    
    return self;
}

- (void)setEntry:(HNEntry *)entry_ {
    [entry autorelease];
    entry = [entry_ retain];
    
    [submitterButton setTitle:[[entry submitter] identifier] forState:UIControlStateNormal];
}

- (void)dealloc {
    [submitterButton release];
    [toolbarContainer release];
    [super dealloc];
}

@end
