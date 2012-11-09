//
//  OpenInSafariActivity.m
//  newsyc
//
//  Created by Grant Paul on 11/8/12.
//
//

#import "OpenInSafariActivity.h"

@implementation OpenInSafariActivity

- (void)dealloc {
    [url release];
    
    [super dealloc];
}

- (NSString *)activityType {
    return @"com.apple.safari.open-in";
}

- (NSString *)activityTitle {
    return @"Open in Safari";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"openinsafari.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    [url release];
    
    url = [[activityItems lastObject] copy];
}

- (void)performActivity {
    [[UIApplication sharedApplication] openURL:url];
    [self activityDidFinish:YES];
}

@end
