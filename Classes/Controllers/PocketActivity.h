//
//  PocketActivity.h
//  newsyc
//
//  Created by Joseph Fabisevich on 1/5/13.
//
//

#import <UIKit/UIKit.h>
#import "PocketAPI.h"
#import "ProgressHUD.h"

@interface PocketActivity : UIActivity <PocketAPIDelegate> {
    ProgressHUD *hud;
}


@end
