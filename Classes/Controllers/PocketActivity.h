//
//  PocketActivity.h
//  newsyc
//
//  Created by Adam Bell on 2013-05-05.
//
//

#import <UIKit/UIKit.h>
#import "PocketAPI.h"
#import "PocketSubmission.h"

@interface PocketActivity : UIActivity {
    NSURL *pocketURL;
    PocketSubmission *submission;
}

@end
