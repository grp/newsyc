//
//  EntryActionsView.m
//  newsyc
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HNKit.h"

#import "EntryActionsView.h"

@implementation EntryActionsView
@synthesize entry, delegate;

- (void)upvoteTapped:(UIButton *)button {
    [delegate entryActionsView:self didSelectItem:kEntryActionsViewItemUpvote];
}

- (void)replyTapped:(UIButton *)button {
    [delegate entryActionsView:self didSelectItem:kEntryActionsViewItemReply];
}

- (void)flagTapped:(UIButton *)button {
    [delegate entryActionsView:self didSelectItem:kEntryActionsViewItemFlag];
}

- (void)downvoteTapped:(UIButton *)button {
    [delegate entryActionsView:self didSelectItem:kEntryActionsViewItemDownvote];
}

- (void)submitterTapped:(UIButton *)button {
    [delegate entryActionsView:self didSelectItem:kEntryActionsViewItemSubmitter];
}

- (void)_updateItems {
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self setItems:[NSArray arrayWithObjects:replyItem, flexibleSpace, upvoteItem, flexibleSpace, flagItem, flexibleSpace, downvoteItem, flexibleSpace, submitterItem, nil]];
    [flexibleSpace release];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setClipsToBounds:YES];
        [self setTintColor:[UIColor colorWithRed:0.9f green:0.3 blue:0.0f alpha:1.0f]];
        
        upvoteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"upvote.png"] style:UIBarButtonItemStylePlain target:self action:@selector(upvoteTapped:)];
        replyItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reply.png"] style:UIBarButtonItemStylePlain target:self action:@selector(replyTapped:)];
        flagItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"flag.png"] style:UIBarButtonItemStylePlain target:self action:@selector(flagTapped:)];
        downvoteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"downvote.png"] style:UIBarButtonItemStylePlain target:self action:@selector(downvoteTapped:)];
        submitterItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profile.png"] style:UIBarButtonItemStylePlain target:self action:@selector(submitterTapped:)];
        
        [self _updateItems];
    }
    
    return self;
}

- (void)setEntry:(HNEntry *)entry_ {
    [entry autorelease];
    entry = [entry_ retain];
    
    [self _updateItems];
}

- (void)dealloc {
    [upvoteItem release];
    [replyItem release];
    [flagItem release];
    [downvoteItem release];
    [submitterItem release];
    
    [super dealloc];
}

@end
