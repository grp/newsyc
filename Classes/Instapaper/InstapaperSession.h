//
//  InstapaperSession.h
//  newsyc
//
//  Created by Grant Paul on 3/10/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "InstapaperAPI.h"

@interface InstapaperSession : NSObject {
    NSString *username;
    NSString *password;
}

+ (id)currentSession;
+ (void)setCurrentSession:(id)session;
+ (void)logoutIfNecessary;

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

- (BOOL)canAddItems;

@end

