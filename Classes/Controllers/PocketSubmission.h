//
//  PocketSubmission.h
//  newsyc
//
//  Created by Joseph Fabisevich on 1/6/13.
//
//

#import <Foundation/Foundation.h>
#import "PocketAPI.h"
#import "ProgressHUD.h"

#define POCKET_CONSUMER_KEY @"YOUR_KEY_HERE"

@interface PocketSubmission : NSObject <PocketAPIDelegate> {
    ProgressHUD *hud;
    NSURL *url;
}

- (id)initWithURL:(NSURL *)submissionURL;
- (void)submitPocketRequest;

@end
