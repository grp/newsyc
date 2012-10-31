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
    [currentSession autorelease];
    currentSession = [session retain];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (session != nil) {
        [defaults setObject:[session username] forKey:@"instapaper-username"];
        [defaults setObject:[session password] forKey:@"instapaper-password"];
    } else {
        [defaults removeObjectForKey:@"instapaper-username"];
        [defaults removeObjectForKey:@"instapaper-password"];
    }
}

+ (void)logoutIfNecessary {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL logout = [[defaults objectForKey:@"instapaper-logout"] boolValue];
    
    if (logout) {
        [defaults setObject:[NSNumber numberWithBool:NO] forKey:@"instapaper-logout"];
        [self setCurrentSession:nil];
    }
}

+ (void)initialize {
    // XXX: use the keychain!
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults objectForKey:@"instapaper-username"];
    NSString *password = [defaults objectForKey:@"instapaper-password"];
    
    if (username != nil && password != nil && [username length] > 0) {
        InstapaperSession *session = [[InstapaperSession alloc] init];
        [session setUsername:username];
        [session setPassword:password];
        [self setCurrentSession:[session autorelease]];
    }
    
    [self logoutIfNecessary];
}

- (BOOL)canAddItems {
    return (username != nil && [username length] > 0);
}

@end
