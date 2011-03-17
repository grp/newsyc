//
//  BrowserController.h
//  Orangey
//
//  Created by Grant Paul on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@interface BrowserController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate> {
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
