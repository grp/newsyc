//
//  OpenInSafariActivity.m
//  newsyc
//
//  Created by Grant Paul on 11/8/12.
//
//

#import "OpenInSafariActivity.h"

@implementation OpenInSafariActivity


- (NSString *)activityType {
    return @"com.apple.safari.open-in";
}

- (NSString *)activityTitle {
    return @"Open in Safari";
}

- (UIImage *)activityImage {
    if ([[self class] respondsToSelector:@selector(activityCategory)]) {
        return [UIImage imageNamed:@"openinsafari7.png"];
    } else {
        return [UIImage imageNamed:@"openinsafari.png"];
    }
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
    url = [[activityItems lastObject] copy];
}

- (void)performActivity {
    [[UIApplication sharedApplication] openURL:url];
    [self activityDidFinish:YES];
}

@end
