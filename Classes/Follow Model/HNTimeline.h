//
//  HNTimeline.h
//  newsyc
//
//  Created by Grant Paul on 8/21/11.
//  Copyright (c) 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNEntryList.h"

#ifdef ENABLE_TIMELINE

#define kHNEntryListIdentifierTimeline @"timeline"

@class HNSession;

@interface HNTimeline : HNEntryList {
    HNSession *session;
    NSMutableSet *loadingUsers;
    NSMutableSet *loadedUsers;
}

+ (HNTimeline *)timelineForSession:(HNSession *)session;

@end

#endif
