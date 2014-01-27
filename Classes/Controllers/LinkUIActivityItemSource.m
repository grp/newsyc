#import "LinkUIActivityItemSource.h"

@implementation LinkUIActivityItemSource

    - (id) initWithURL: (NSURL *) url andSubject: (NSString *) subject {
        if (self = [super init]) {
            self.url = url;
            self.subject = subject;
        }
        
        return self;
    }

    - (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
        return self.url;
    }

    - (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
        return self.url;
    }

    - (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
        return self.subject;
    }

@end
