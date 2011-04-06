//
//  BrowserController.h
//  newsyc
//
//  Created by Grant Paul on 3/7/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "LoginController.h"

@interface BrowserController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, LoginControllerDelegate> {
    UIWebView *webview;
    UIToolbar *toolbar;
    NSURL *rootURL;
    NSURL *currentURL;
    UIBarButtonItem *backItem;
    UIBarButtonItem *forwardItem;
    UIBarButtonItem *loadingItem;
    UIBarButtonItem *refreshItem;
    UIBarButtonItem *shareItem;
    UIBarButtonItem *spacerItem;
}

@property (nonatomic, copy) NSURL *currentURL;

- (id)initWithURL:(NSURL *)url;

@end
