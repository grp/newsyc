//
//  HNSessionController.h
//  newsyc
//
//  Created by Grant Paul on 1/8/13.
//
//

#import "HNKit.h"

extern NSString *kHNSessionControllerSessionsChangedNotification;

@class HNSession;

@interface HNSessionController : NSObject {
    NSMutableArray *sessions;
}

+ (id)sessionController;

@property (nonatomic, copy, readonly) NSArray *sessions;
@property (nonatomic, retain) HNSession *recentSession;

- (NSInteger)numberOfSessions;

- (void)addSession:(HNSession *)session;
- (void)removeSession:(HNSession *)session;
- (void)moveSession:(HNSession *)session toIndex:(NSInteger)index;

- (void)refresh;

@end
