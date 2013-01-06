//
//  PocketActivity.m
//  newsyc
//
//  Created by Joseph Fabisevich on 1/5/13.
//
//

#import "PocketActivity.h"
#import "ProgressHUD.h"

@implementation PocketActivity

- (void)dealloc
{
    [pocketSubmission release];
    [super dealloc];
}

- (NSString *)activityType {
    return @"pocket-oauth-v1";
}

- (NSString *)activityTitle {
    return @"Pocket It";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"pocket.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    [pocketSubmission release];
    pocketSubmission = [[PocketSubmission alloc] initWithURL:[activityItems objectAtIndex:0]];
}

- (void)performActivity {
    [pocketSubmission submitPocketRequest];
    [self activityDidFinish:YES];
}


@end
