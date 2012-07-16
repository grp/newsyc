//
//  HNAnonymousSession.h
//  newsyc
//
//  Created by Grant Paul on 4/13/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "HNKit.h"
#import "HNSession.h"

@interface HNAnonymousSession : HNSession

@end

@interface HNSession (HNAnonymousSession)

@property (nonatomic, readonly) BOOL isAnonymous;

@end
