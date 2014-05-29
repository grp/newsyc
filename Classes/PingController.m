//
//  PingController.m
//  newsyc
//
//  Created by Grant Paul on 1/19/13.
//

#include <sys/types.h>
#include <sys/sysctl.h>

#import <HNKit/NSString+URLEncoding.h>

#import "PingController.h"

@implementation PingController
@synthesize delegate, locked;

- (NSString *)version {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
}

- (NSString *)bundleIdentifier {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
}

- (NSString *) platform {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);

    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);

    NSString *platform = @(machine);
    free(machine);

    return platform;
}

- (void)ping {
    NSString *appv = [self version];
    NSString *sysv = [[UIDevice currentDevice] systemVersion];
    NSString *dev = [[UIDevice currentDevice] model];
    NSString *bundle = [self bundleIdentifier];
    NSString *platform = [self platform];
    NSString *from = [[NSUserDefaults standardUserDefaults] objectForKey:@"current-version"] ?: @"";
    BOOL seen = [[NSUserDefaults standardUserDefaults] boolForKey:@"initial-install-seen"];

    received = [[NSMutableData alloc] init];

    NSString *url = [NSString stringWithFormat:@"http://newsyc.me/ping?appv=%@&sysv=%@&dev=%@&seen=%d&oldv=%@&bundle=%@&platform=%@", [appv stringByURLEncodingString], [sysv stringByURLEncodingString], [dev stringByURLEncodingString], seen, [from stringByURLEncodingString], [bundle stringByURLEncodingString], [platform stringByURLEncodingString]];
    NSURL *requestURL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
}

- (void)connection:(NSURLConnection *)connection_ didReceiveData:(NSData *)data {
    [received appendData:data];
}

- (void)connection:(NSURLConnection *)connection_ didFailWithError:(NSError *)error {
    received = nil;

    if ([delegate respondsToSelector:@selector(pingController:failedWithError:)]) {
        [delegate pingController:self failedWithError:error];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    id representation = [NSJSONSerialization JSONObjectWithData:received options:0 error:NULL];

    if ([representation isKindOfClass:[NSDictionary class]]) {
        NSString *message = representation[@"message"];
        NSString *title = representation[@"title"];
        NSString *button = representation[@"button"];
        NSString *moreButton = representation[@"more-button"];
        NSString *moreURL = representation[@"more-url"];

        locked = [representation[@"locked"] boolValue];

        if (locked) {
            UIWindow *lockedWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            [lockedWindow setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            [lockedWindow setBackgroundColor:[UIColor darkGrayColor]];

            UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
            [keyWindow setHidden:YES];

            [lockedWindow makeKeyAndVisible];
        }

        if (title != nil) {
            if (button == nil) button = @"Continue";

            UIAlertView *alert = [[UIAlertView alloc] init];
            [alert setDelegate:self];
            [alert setTitle:title];
            [alert setMessage:message];
            if (!locked) {
                [alert addButtonWithTitle:button];

                if (moreButton != nil && moreURL != nil) {
                    [alert addButtonWithTitle:moreButton];

                    moreInfoURL = [NSURL URLWithString:moreURL];
                }
            }
            [alert show];
        }
    }

    [[NSUserDefaults standardUserDefaults] setObject:[self version] forKey:@"current-version"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"initial-install-seen"];

    received = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    moreInfoURL = nil;

    if (buttonIndex == 1) {
        if ([delegate respondsToSelector:@selector(pingController:completedAcceptingURL:)]) {
            [delegate pingController:self completedAcceptingURL:moreInfoURL];
        }
    } else {
        if ([delegate respondsToSelector:@selector(pingControllerCompletedWithoutAction:)]) {
            [delegate pingControllerCompletedWithoutAction:self];
        }
    }
}

@end
