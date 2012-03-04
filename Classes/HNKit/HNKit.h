//
//  HNKit.h
//  newsyc
//
//  Created by Grant Paul on 3/4/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

// This is the main header file for the HNKit "framework",
// which has the singular purpose of scraping Hacker News.
//
// HNKit depends on the files in the "XML" directory, as
// well as few files in the "Categories" folder as well.

#import "HNShared.h"

// data
#import "HNObject.h"
#import "HNUser.h"
#import "HNContainer.h"
#import "HNEntry.h"
#import "HNEntryList.h"

// sessions
#import "HNSession.h"
#import "HNAnonymousSession.h"
#import "HNSessionAuthenticator.h"
#import "HNSubmission.h"

// internal
#import "HNAPIRequest.h"
#import "HNAPIRequestParser.h"
#import "HNAPISubmission.h"

#ifdef HNKIT_RENDERING_ENABLED
// rendering
#import "HNEntryBodyRenderer.h"
#endif
