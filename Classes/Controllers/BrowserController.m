//
//  BrowserController.m
//  newsyc
//
//  Created by Grant Paul on 3/7/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "BrowserController.h"

#import "SharingController.h"
#import "NavigationController.h"

#import "ProgressHUD.h"
#import "NSArray+Strings.h"
#import "UIColor+Orange.h"
#import "UIApplication+ActivityIndicator.h"
#import "UINavigationItem+MultipleItems.h"

@implementation BrowserController
@synthesize currentURL;

- (id)initWithURL:(NSURL *)url {
    if ((self = [super init])) {
        rootURL = url;
        [self setCurrentURL:url];
        [self setHidesBottomBarWhenPushed:YES];
    }
    
    return self;
}

- (void)retainNetworkIndicator {
    [[UIApplication sharedApplication] retainNetworkActivityIndicator];
    networkRetainCount += 1;
}

- (void)releaseNetworkIndicator {
    [[UIApplication sharedApplication] releaseNetworkActivityIndicator];
    networkRetainCount -= 1;
}

- (void)releaseNetworkIndicatorCompletely {
    // there may be multiple connections open on the webview, so we have
    // to keep track of how many are open ourselves and release the indicator
    // that many times to make sure it is properly hidden when we are popped
    for (NSInteger i = 0; i < networkRetainCount; i++) {
        [[UIApplication sharedApplication] releaseNetworkActivityIndicator];
    }
}

- (void)dealloc {
    [webview setDelegate:nil];
    [self releaseNetworkIndicatorCompletely];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [webview release];
    [toolbar release];
    [toolbarItem release];
    [backItem release];
    [forwardItem release];
    [shareItem release];
    [refreshItem release];
    [loadingItem release];
    [spacerItem release];
    
    [super dealloc];
}

- (void)updateToolbarItems {
    [backItem setEnabled:[webview canGoBack]];
    [forwardItem setEnabled:[webview canGoForward]];
    
    BarButtonItem *changableItem = nil;
    if ([webview isLoading]) changableItem = loadingItem;
    else changableItem = refreshItem;
    
    [toolbar setItems:[NSArray arrayWithObjects:spacerItem, backItem, spacerItem, spacerItem, forwardItem, spacerItem, spacerItem, spacerItem, readabilityItem, spacerItem, spacerItem, changableItem, spacerItem, spacerItem, shareItem, spacerItem, nil]];
}

- (UIImage *)_modernImageWithName:(NSString *)name {
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        name = [name stringByAppendingString:@"7"];
    }

    name = [name stringByAppendingString:@".png"];

    return [UIImage imageNamed:name];
}

- (void)loadView {
    [super loadView];

    [[self view] setClipsToBounds:YES];
    [[self view] setBackgroundColor:[UIColor whiteColor]];

    toolbar = [[OrangeToolbar alloc] init];
    [toolbar sizeToFit];
    
    backItem = [[BarButtonItem alloc] initWithImage:[self _modernImageWithName:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    forwardItem = [[BarButtonItem alloc] initWithImage:[self _modernImageWithName:@"forward"] style:UIBarButtonItemStylePlain target:self action:@selector(goForward)];
    readabilityItem = [[BarButtonItem alloc] initWithImage:[UIImage imageNamed:@"readability.png"] style:UIBarButtonItemStylePlain target:self action:@selector(readability)];
    refreshItem = [[BarButtonItem alloc] initWithImage:[self _modernImageWithName:@"refresh"] style:UIBarButtonItemStylePlain target:self action:@selector(reload)];
    shareItem = [[BarButtonItem alloc] initWithImage:[self _modernImageWithName:@"action"] style:UIBarButtonItemStylePlain target:self action:@selector(share)];
    spacerItem = [[BarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    loadingItem = [[ActivityIndicatorItem alloc] initWithSize:[[refreshItem image] size]];
    [self updateToolbarItems];
    
    webview = [[UIWebView alloc] initWithFrame:[[self view] bounds]];
    webview.backgroundColor = [UIColor whiteColor];
    [webview setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [webview setDelegate:self];
    [webview setScalesPageToFit:YES];
    [webview setClipsToBounds:NO];
    [[webview scrollView] setClipsToBounds:NO];
    [[self view] addSubview:webview];
}
    
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![webview request]) {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:rootURL];
        [webview loadRequest:[request autorelease]];
    }

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && [toolbar respondsToSelector:@selector(setBarTintColor:)]) {
        // On iOS 7, toolbars are transparent, so showing orange on top of orange looks wrong.
        [toolbar setOrange:NO];
    } else {
        [toolbar setOrange:![[NSUserDefaults standardUserDefaults] boolForKey:@"disable-orange"]];
    }

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"disable-orange"] && ([toolbar respondsToSelector:@selector(setBarTintColor:)] || [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)) {
        [[loadingItem spinner] setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    } else {
        [[loadingItem spinner] setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        CGRect toolbarFrame = [toolbar bounds];
        toolbarFrame.origin.y = [[self view] bounds].size.height - toolbarFrame.size.height;
        toolbarFrame.size.width = [[self view] bounds].size.width;
        [toolbar setFrame:toolbarFrame];
        [toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        [[self view] addSubview:toolbar];
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        CGRect toolbarFrame = [toolbar bounds];
        toolbarFrame.size.width = 280.0f;
        [toolbar setFrame:toolbarFrame];
        
        [toolbar setBackgroundImage:[UIImage imageNamed:@"clear.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        toolbarItem = [[BarButtonItem alloc] initWithCustomView:toolbar];
        [[self navigationItem] addRightBarButtonItem:toolbarItem atPosition:UINavigationItemPositionLeft];

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && [toolbar respondsToSelector:@selector(setBarTintColor:)]) {
            // Hide the top border line.
            [toolbar setClipsToBounds:YES];
            [toolbar setBounds:CGRectMake(0, 1, [toolbar bounds].size.width, [toolbar bounds].size.height)];
        }
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [webview setDelegate:nil];
    [self releaseNetworkIndicatorCompletely];
    
    [[self navigationItem] removeRightBarButtonItem:toolbarItem];
    
    [webview release];
    webview = nil;
    [toolbar release];
    toolbar = nil;
    [toolbarItem release];
    toolbarItem = nil;
    [backItem release];
    backItem = nil;
    [forwardItem release];
    forwardItem = nil;
    [readabilityItem release];
    readabilityItem = nil;
    [refreshItem release];
    refreshItem = nil;
    [shareItem release];
    shareItem = nil;
    [loadingItem release];
    loadingItem = nil;
    [spacerItem release];
    spacerItem = nil;
}

- (void)readability {
    [webview stringByEvaluatingJavaScriptFromString:kReadabilityBookmarkletCode];
}

- (NSString *)pageTitle {
    return [webview stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)reload {
    [webview reload];
}

- (void)stop {
    [webview stopLoading];
}

- (void)goBack {
    [webview goBack];
}

- (void)goForward {
    [webview goForward];
}

- (void)share {
    SharingController *sharingController = [[SharingController alloc] initWithURL:currentURL title:[self pageTitle] fromController:self];
    [sharingController showFromBarButtonItem:shareItem];
    [sharingController release];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self updateToolbarItems];
    
    [self releaseNetworkIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self updateToolbarItems];
    [self setCurrentURL:[[webView request] URL]];
    [[self navigationItem] setTitle:[self pageTitle]];
    
    [self releaseNetworkIndicator];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // Update the webview insets.
        // We do this after loading the content due to a bug in iOS7+ that will render
        // the area outside of the insets as black
        UIEdgeInsets webviewInsets = webview.scrollView.contentInset;
        webviewInsets.bottom = toolbar.frame.size.height;
        webview.scrollView.contentInset = webviewInsets;
        webview.scrollView.scrollIndicatorInsets = webview.scrollView.contentInset;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self retainNetworkIndicator];
    
    [self updateToolbarItems];
}

// These 3 methods from Apple tech doc: http://developer.apple.com/library/ios/#qa/qa1629/_index.html
- (void)openExternalURL:(NSURL *)external {
    externalURL = [external retain];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:external] delegate:self startImmediately:YES];
    [conn release];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if (response) externalURL = [[response URL] retain];
    return request;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Opening Link" message:@"Are you sure you want to leave news:yc to open this link?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Open Link", nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:externalURL];
    }
    
    [externalURL release];
    externalURL = nil;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [alertView release];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [self updateToolbarItems];
    
    NSArray *hosts = [NSArray arrayWithObjects:@"itunes.apple.com", @"phobos.apple.com", @"youtube.com", @"maps.google.com", nil];
    NSURL *url = [request URL];
    if (navigationType == UIWebViewNavigationTypeLinkClicked && [hosts containsString:[url host]]) {
        [self openExternalURL:url];
        return NO;
    }
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked ||
        navigationType == UIWebViewNavigationTypeFormSubmitted ||
        navigationType == UIWebViewNavigationTypeFormResubmitted) {
        [self setCurrentURL:[request URL]];
    }
    
    return YES;
}

AUTOROTATION_FOR_PAD_ONLY

@end
