//
//  BrowserController.m
//  newsyc
//
//  Created by Grant Paul on 3/7/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import "BrowserController.h"

#import "InstapaperController.h"
#import "NavigationController.h"

#import "ProgressHUD.h"
#import "NSArray+Strings.h"
#import "UIApplication+ActivityIndicator.h"

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
    for (int i = 0; i < networkRetainCount; i++) {
        [[UIApplication sharedApplication] releaseNetworkActivityIndicator];
    }
}

- (void)dealloc {
    [self releaseNetworkIndicatorCompletely];
    
    [webview setDelegate:nil];
    [webview release];
    [toolbar release];
    
    [backItem release];
    [forwardItem release];
    [shareItem release];
    [refreshItem release];
    [loadingItem release];
    [spacerItem release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (void)updateToolbarItems {
    [backItem setEnabled:[webview canGoBack]];
    [forwardItem setEnabled:[webview canGoForward]];
    
    UIBarButtonItem *changableItem = nil;
    if ([webview isLoading]) changableItem = loadingItem;
    else changableItem = refreshItem;
    
    [toolbar setItems:[NSArray arrayWithObjects:spacerItem, backItem, spacerItem, spacerItem, forwardItem, spacerItem, spacerItem, spacerItem, readabilityItem, spacerItem, spacerItem, changableItem, spacerItem, spacerItem, shareItem, spacerItem, nil]];
}

- (void)loadView {
    [super loadView];
    
    toolbar = [[UIToolbar alloc] init];
    [toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    
    [toolbar sizeToFit];
    CGRect toolbarFrame = [toolbar bounds];
    toolbarFrame.origin.y = [[self view] bounds].size.height - toolbarFrame.size.height;
    [toolbar setFrame:toolbarFrame];
    [[self view] addSubview:toolbar];
    
    backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    forwardItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forward.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goForward)];
    readabilityItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"readability.png"] style:UIBarButtonItemStylePlain target:self action:@selector(readability)];
    refreshItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh.png"] style:UIBarButtonItemStylePlain target:self action:@selector(reload)];
    shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionMenu)];
    spacerItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    loadingItem = [[ActivityIndicatorItem alloc] initWithSize:[[refreshItem image] size]];
    [self updateToolbarItems];
    
    CGRect webviewFrame = [[self view] bounds];
    webviewFrame.size.height -= toolbarFrame.size.height;
    webview = [[UIWebView alloc] initWithFrame:webviewFrame];
    [webview setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [webview setDelegate:self];
    [webview setScalesPageToFit:YES];
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
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disable-orange"]) {
        [toolbar setTintColor:[UIColor colorWithRed:1.0f green:0.4f blue:0.0f alpha:1.0f]];
    } else {
        [toolbar setTintColor:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [self releaseNetworkIndicatorCompletely];
    
    [webview setDelegate:nil];
    [webview release];
    webview = nil;
    
    [toolbar release];
    toolbar = nil;
    
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

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)actionSheet:(UIActionSheet *)action clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [action cancelButtonIndex]) return;
    
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:currentURL];
    } else if ([MFMailComposeViewController canSendMail] && buttonIndex == 1) {
        MFMailComposeViewController *composeController = [[MFMailComposeViewController alloc] init];
        [composeController setMailComposeDelegate:self];
        
        NSString *urlString = [currentURL absoluteString];
        NSString *body = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", urlString, urlString];
        [composeController setMessageBody:body isHTML:YES];
        
        [self presentModalViewController:[composeController autorelease] animated:YES];
    } else if (([MFMailComposeViewController canSendMail] && buttonIndex == 2) || (![MFMailComposeViewController canSendMail] && buttonIndex == 1)) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setURL:currentURL];
        [pasteboard setString:[currentURL absoluteString]];
        
        ProgressHUD *copied = [[ProgressHUD alloc] init];
        [copied setState:kProgressHUDStateCompleted];
        [copied setText:@"Copied!"];
        [copied showInWindow:[[self view] window]];
        [copied dismissAfterDelay:0.8f animated:YES];
        [copied release];
    } else if (([MFMailComposeViewController canSendMail] && buttonIndex == 3) || (![MFMailComposeViewController canSendMail] && buttonIndex == 2)) {
        [[InstapaperController sharedInstance] submitURL:currentURL fromController:self];
    } 
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

- (void)showActionMenu {
    UIActionSheet *sheet = [[UIActionSheet alloc]
        initWithTitle:[currentURL absoluteString]
        delegate:self
        cancelButtonTitle:nil
        destructiveButtonTitle:nil
        otherButtonTitles:nil
    ];
    
    [sheet addButtonWithTitle:@"Open with Safari"];
    if ([MFMailComposeViewController canSendMail]) [sheet addButtonWithTitle:@"Mail Link"];
    [sheet addButtonWithTitle:@"Copy Link"];
    [sheet addButtonWithTitle:@"Read Later"];
    [sheet addButtonWithTitle:@"Cancel"];
    [sheet setCancelButtonIndex:([sheet numberOfButtons] - 1)];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [sheet showFromBarButtonItem:shareItem animated:YES];
    else [sheet showInView:[[self view] window]];
    
    [sheet release];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self updateToolbarItems];
    
    [self releaseNetworkIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self updateToolbarItems];
    [self setCurrentURL:[[webView request] URL]];
    [[self navigationItem] setTitle:[webview stringByEvaluatingJavaScriptFromString:@"document.title"]];
    
    [self releaseNetworkIndicator];
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
