//
//  PingController.h
//  newsyc
//
//  Created by Grant Paul on 1/19/13.
//
//

@protocol PingControllerDelegate;

@interface PingController : NSObject {
    NSMutableData *received;
    NSURL *moreInfoURL;
    BOOL locked;

    id<PingControllerDelegate> __weak delegate;
}

@property (nonatomic, weak) id<PingControllerDelegate> delegate;
@property (nonatomic, assign) BOOL locked;

- (void)ping;

@end

@protocol PingControllerDelegate <NSObject>
@optional

- (void)pingController:(PingController *)pingController failedWithError:(NSError *)error;
- (void)pingControllerCompletedWithoutAction:(PingController *)pingController;
- (void)pingController:(PingController *)pingController completedAcceptingURL:(NSURL *)url;


@end
