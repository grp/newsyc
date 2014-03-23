//
//  OpenInChromeActivity.m
//  newsyc
//
//  Created by Ayberk Tosun on 23/3/14.
//
//

#import "OpenInChromeActivity.h"
#import "OpenInChromeController.h"

@implementation OpenInChromeActivity

- (void)dealloc {
    [url release];
    
    [super dealloc];
}

- (NSString *)activityTitle {
    return @"Open in Chrome";
}

//- (UIImage *)activityImage {
//    TODO: Return "open in chrome" logo here
//}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    [url release];
    
    url = [[activityItems lastObject] copy];
}

- (void)performActivity {
    OpenInChromeController *chromeController = [[OpenInChromeController alloc] init];
    [chromeController openInChrome:url];
    [self activityDidFinish:YES];
}

@end
