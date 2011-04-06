//
//  InstapaperLoginController.h
//  newsyc
//
//  Created by Alex Galonsky on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginController.h"

@interface InstapaperLoginController : LoginController <LoginControllerDelegate>{

}
- (id) initWithMessage: (NSString *) message;
@end
