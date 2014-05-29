//
//  ReadLaterActivity.m
//  newsyc
//
//  Created by Mark Nemec on 22/10/12.
//
//

#import "InstapaperActivity.h"
#import "InstapaperSubmission.h"

@implementation InstapaperActivity


- (NSString *)activityType {
    return @"com.instapaper.instapaper.read-later";
}

- (NSString *)activityTitle {
    return @"Read Later";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"instapaper.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
    submission = [[InstapaperSubmission alloc] initWithURL:activityItems[0]];
    
    [submission setLoginCompletion:^(BOOL loggedIn) {
        [self activityDidFinish:YES];
    }];
}

- (UIViewController *)activityViewController {
    return [submission submitFromController:nil];
}

- (void)performActivity {
    [self activityDidFinish:YES];
}

@end
