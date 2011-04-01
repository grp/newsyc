//
//  HeaderContainerView.m
//  Orangey
//
//  Created by Grant Paul on 3/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNKit.h"

#import "HeaderContainerView.h"
#import "DetailsHeaderView.h"
#import "SubmissionDetailsHeaderView.h"
#import "CommentDetailsHeaderView.h"
#import "EntryActionsView.h"

@implementation HeaderContainerView
@synthesize detailsHeaderView, entry;

- (id)initWithEntry:(HNEntry *)entry_ widthWidth:(CGFloat)width {
    if ((self = [super init])) {
        [self setEntry:entry_];
        
        Class headerViewClass = nil;
        if ([entry destination] != nil) headerViewClass = [SubmissionDetailsHeaderView class];
        else headerViewClass = [CommentDetailsHeaderView class];
        
        detailsHeaderView = [[headerViewClass alloc] initWithFrame:CGRectZero];
        [detailsHeaderView setEntry:entry];
        CGRect headerrect;
        headerrect.origin = CGPointZero;
        headerrect.size.width = width;
        headerrect.size.height = [detailsHeaderView suggestedHeightWithWidth:headerrect.size.width];
        [detailsHeaderView setFrame:headerrect];
        [self addSubview:detailsHeaderView];
        
        CGRect selfrect;
        selfrect.size.width = width;
        selfrect.size.height = [detailsHeaderView bounds].size.height;
        selfrect.origin = CGPointZero;
        [self setFrame:selfrect];
    }
    
    return self;
}

- (void)dealloc {
    [detailsHeaderView release];
    
    [super dealloc];
}

@end
