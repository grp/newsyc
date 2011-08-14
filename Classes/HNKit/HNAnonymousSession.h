//
//  HNAnonymousSession.h
//  newsyc
//
//  Created by Grant Paul on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNKit.h"
#import "HNSession.h"

@interface HNSession (HNAnonymousSession)

@property (nonatomic, readonly) BOOL isAnonymous;

@end

@interface HNAnonymousSession : HNSession {
    
}

@end
