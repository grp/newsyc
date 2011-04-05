//
//  UIActionSheet+Context.m
//  newsyc
//
//  Created by Grant Paul on 3/31/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import <objc/runtime.h>

#import "UIActionSheet+Context.h"

@implementation UIActionSheet (Context)
static NSString *UIActionSheetNameKey = @"UIActionSheetSheetContextKey";

- (void)setSheetContext:(NSString *)name {
    objc_setAssociatedObject(self, &UIActionSheetNameKey, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)sheetContext {
    return objc_getAssociatedObject(self, &UIActionSheetNameKey);
}

@end
