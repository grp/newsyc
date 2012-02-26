//
//  InstapaperController.h
//  newsyc
//
//  Created by Grant Paul on 2/24/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "InstapaperLoginController.h"

@interface InstapaperController : NSObject <LoginControllerDelegate> {
    
}

+ (id)sharedInstance;

- (void)submitURL:(NSURL *)url fromController:(UIViewController *)controller;

@end
