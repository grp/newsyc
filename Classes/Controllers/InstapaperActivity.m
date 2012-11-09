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

- (void)dealloc {
    [submission release];

    [super dealloc];
}

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
    [submission release];
    
    submission = [[InstapaperSubmission alloc] initWithURL:[activityItems objectAtIndex:0]];
    
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
