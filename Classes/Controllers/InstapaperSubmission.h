//
//  InstapaperSubmission.h
//  newsyc
//
//  Created by Grant Paul on 10/30/12.
//
//

@class LoadingController;

@interface InstapaperSubmission : NSObject {
    NSURL *url;
    BOOL presented;
    void (^loginCompletion)(BOOL);
}

@property (nonatomic, copy) void (^loginCompletion)(BOOL);

- (id)initWithURL:(NSURL *)url;
- (UIViewController *)submitFromController:(UIViewController *)controller;

@end
