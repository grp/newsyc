//
//  PocketActivity.m
//  newsyc
//
//  Created by Adam Bell on 2013-05-05.
//
//

#import "PocketActivity.h"


@implementation PocketActivity

- (void)dealloc {
    [super dealloc];
}

- (NSString *)activityType {
    return @"com.pocket.pocket.save-url";
}

- (NSString *)activityTitle {
    return @"Save to Pocket";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"pocket.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    pocketURL = activityItems[0];
    submission = [[PocketSubmission alloc] initWithURL:activityItems[0]];
    
    [self activityDidFinish:YES];
}

- (UIViewController *)activityViewController {
    return [submission submitFromController:nil];
}

- (void)performActivity {
    [self activityDidFinish:YES];
}

+ (void)logoutIfNecessary {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL logout = [[defaults objectForKey:@"instapaper-logout"] boolValue];
    
    if (logout) {
        [defaults setObject:[NSNumber numberWithBool:NO] forKey:@"instapaper-logout"];
        [[PocketAPI sharedAPI] logout];
    }
}

@end
