#import <Foundation/Foundation.h>
#import "UIKit/UIActivityItemProvider.h"

@interface LinkUIActivityItemSource : NSObject <UIActivityItemSource>

    @property (strong, nonatomic) NSURL *url;
    @property (strong, nonatomic) NSString *subject;

    - (id) initWithURL: (NSURL *) url andSubject: (NSString *) subject;

@end
