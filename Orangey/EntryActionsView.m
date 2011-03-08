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
#import "SolidToolbar.h"

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

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setClipsToBounds:YES];
        
        submitterButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        CGFloat buttonWidth = [self bounds].size.width * 0.385f;
        [submitterButton setFrame:CGRectMake([self bounds].size.width - buttonWidth - 15.0f, -2.0f, buttonWidth + 30.0f, [self bounds].size.height + 4.0f)];
        [self addSubview:submitterButton];
        [submitterButton addTarget:self action:@selector(submitterTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *upvote = [UIButton buttonWithType:UIButtonTypeCustom];
        [upvote setFrame:CGRectMake(0, 0, 21.0f, 18.0f)];
        [upvote setImage:[UIImage imageNamed:@"upvote.png"] forState:UIControlStateNormal];
        [upvote addTarget:self action:@selector(upvoteTapped:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *upvoteItem = [[UIBarButtonItem alloc] initWithCustomView:upvote];
        
        UIButton *reply = [UIButton buttonWithType:UIButtonTypeCustom];
        [reply setFrame:CGRectMake(0, 0, 25.0f, 20.0f)];
        [reply setImage:[UIImage imageNamed:@"reply.png"] forState:UIControlStateNormal];
        [reply addTarget:self action:@selector(upvoteTapped:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *replyItem = [[UIBarButtonItem alloc] initWithCustomView:reply];
        
        UIButton *flag = [UIButton buttonWithType:UIButtonTypeCustom];
        [flag setFrame:CGRectMake(0, 0, 25.0f, 20.0f)];
        [flag setImage:[UIImage imageNamed:@"flag.png"] forState:UIControlStateNormal];
        [flag addTarget:self action:@selector(flagTapped:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *flagItem = [[UIBarButtonItem alloc] initWithCustomView:flag];
        
        UIButton *downvote = [UIButton buttonWithType:UIButtonTypeCustom];
        [downvote setFrame:CGRectMake(0, 0, 21.0f, 18.0f)];
        [downvote setImage:[UIImage imageNamed:@"downvote.png"] forState:UIControlStateNormal];
        [downvote addTarget:self action:@selector(downvoteTapped:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *downvoteItem = [[UIBarButtonItem alloc] initWithCustomView:downvote];
        
        UIBarButtonItem *padding1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
        UIBarButtonItem *padding2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
        UIBarButtonItem *padding3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
        
        toolbar = [[SolidToolbar alloc] initWithFrame:CGRectMake(0, 0, [self bounds].size.width - buttonWidth, [self bounds].size.height)];
        [toolbar setItems:[NSArray arrayWithObjects:[upvoteItem autorelease], [padding1 autorelease], [replyItem autorelease], [padding2 autorelease], [flagItem autorelease], [padding3 autorelease], [downvoteItem autorelease], nil]];
        [toolbar setTintColor:[UIColor whiteColor]];
        [self addSubview:toolbar];
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
    [toolbar release];
    
    [super dealloc];
}

@end
