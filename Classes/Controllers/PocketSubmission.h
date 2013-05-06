//
//  PocketSubmission.h
//  newsyc
//
//  Created by Adam Bell on 2013-05-05.
//
//

#import "ProgressHUD.h"
#import "PocketAPI.h"

@interface PocketSubmission : NSObject {
    NSURL *url;
    BOOL presented;
}

- (id)initWithURL:(NSURL *)url;
- (UIViewController *)submitFromController:(UIViewController *)controller;

@end
