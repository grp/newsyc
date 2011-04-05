//
//  StatusDelegate.h
//  newsyc
//
//  Created by Grant Paul on 3/10/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

typedef enum {
    kStatusDelegateTypeNotice,
    kStatusDelegateTypeWarning,
    kStatusDelegateTypeError,
    kStatusDelegateTypeCritical
} StatusDelegateType;

@protocol StatusDelegate<NSObject>

- (void)handleStatusEventWithType:(StatusDelegateType)type message:(NSString *)message;

@end
