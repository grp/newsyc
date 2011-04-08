//
//  InstapaperSession.m
//  newsyc
//
//  Created by Grant Paul on 3/10/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "InstapaperSession.h"

@implementation InstapaperSession
@synthesize username, password;

static id currentSession = nil;

+ (id)currentSession {
    return currentSession;
}

+ (void)setCurrentSession:(id)session {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[session username] forKey:@"instapaper-username"];
    [defaults setObject:[session password] forKey:@"instapaper-password"];
    
    [currentSession autorelease];
    currentSession = session;
}

+ (void)initialize {
    // XXX: is it safe to use NSUserDefaults here?
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults objectForKey:@"instapaper-username"];
    NSString *password = [defaults objectForKey:@"instapaper-password"];
    
    if (username != nil && password != nil && [username length] > 0) {
        InstapaperSession *session = [[InstapaperSession alloc] init];
        [session setUsername:username];
        [session setPassword:password];
        [self setCurrentSession:[session autorelease]];
    }
}

- (BOOL)canAddItems {
    return username != nil && [username length] > 0;
}

@end
