//
//  HNSessionController.m
//  newsyc
//
//  Created by Grant Paul on 1/8/13.
//
//

#import "HNSessionController.h"
#import "HNSession.h"
#import "HNAnonymousSession.h"
#import "HNObjectCache.h"

NSString *kHNSessionControllerSessionsChangedNotification = @"HNSessionControllerSessionsChangedNotification";

@implementation HNSessionController
@synthesize recentSession;

+ (id)sessionController {
    static HNSessionController *sessionController = nil;

    static dispatch_once_t sessionControllerToken;
    dispatch_once(&sessionControllerToken, ^{
        sessionController = [[HNSessionController alloc] init];
    });

    return sessionController;
}

- (id)init {
    if ((self = [super init])) {
        sessions = [[NSMutableArray alloc] init];

        // FIXME: This should use the Keychain, not NSUserDefaults.
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

        NSArray *allSessionsArray = [userDefaults objectForKey:@"HNKit:HNSessionController:Sessions"];
        NSString *recentIdentifier = [userDefaults objectForKey:@"HNKit:HNSessionController:RecentSession"];

        for (NSDictionary *sessionDictionary in allSessionsArray) {
            HNSession *session = [[HNSession alloc] initWithSessionDictionary:sessionDictionary];
            [sessions addObject:session];
            [session release];

            if ([recentIdentifier isEqualToString:[session identifier]]) {
                [self setRecentSession:session];
            }
        }

        HNSessionToken token = (HNSessionToken) [userDefaults objectForKey:@"HNKit:SessionToken"];
        NSString *password = [userDefaults objectForKey:@"HNKit:SessionPassword"];
        NSString *name = [userDefaults objectForKey:@"HNKit:SessionName"];

        if (token != nil && password != nil && name != nil) {
            // Restore old-style single-account sessions.
            HNSession *session = [[HNSession alloc] initWithUsername:name password:password token:token];
            [self addSession:session];
            [self setRecentSession:session];
            [session release];

            [userDefaults removeObjectForKey:@"HNKit:SessionToken"];
            [userDefaults removeObjectForKey:@"HNKit:SessionPassword"];
            [userDefaults removeObjectForKey:@"HNKit:SessionName"];
        }
    }

    return self;
}

- (NSArray *)sessions {
    return [[sessions copy] autorelease];
}

- (void)refresh {
    for (HNSession *session in sessions) {
        [session reloadToken];
    }
}

- (NSInteger)numberOfSessions {
    return [sessions count];
}

- (void)setRecentSession:(HNSession *)recentSession_ {
    // This wouldn't even make sense.
    if ([recentSession_ isAnonymous]) return;

    [recentSession release];
    recentSession = [recentSession_ retain];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[recentSession identifier] forKey:@"HNKit:HNSessionController:RecentSession"];
    [userDefaults synchronize];
}

- (void)saveSessions {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *allSessionsArray = [NSMutableArray array];

    for (HNSession *session in sessions) {
        NSDictionary *sessionDictionary = [session sessionDictionary];
        [allSessionsArray addObject:sessionDictionary];
    }

    [userDefaults setObject:allSessionsArray forKey:@"HNKit:HNSessionController:Sessions"];
    [userDefaults synchronize];
}

- (void)addSession:(HNSession *)session {
    NSAssert(![session isAnonymous], @"Sessions must not be anonymous.");

    [sessions addObject:session];
    [self saveSessions];

    [[NSNotificationCenter defaultCenter] postNotificationName:kHNSessionControllerSessionsChangedNotification object:self];
}

- (void)removeSession:(HNSession *)session {
    [[session cache] clearPersistentCache];

    [sessions removeObject:session];
    [self saveSessions];

    [[NSNotificationCenter defaultCenter] postNotificationName:kHNSessionControllerSessionsChangedNotification object:self];
}

- (void)moveSession:(HNSession *)session toIndex:(NSInteger)index {
    NSInteger from = [sessions indexOfObject:session];

    [session retain];
    [sessions removeObjectAtIndex:from];
    
    if (index >= [sessions count]) {
        [sessions addObject:session];
    } else {
        [sessions insertObject:session atIndex:index];
    }

    [session release];

    [self saveSessions];

    [[NSNotificationCenter defaultCenter] postNotificationName:kHNSessionControllerSessionsChangedNotification object:self];
}

@end
