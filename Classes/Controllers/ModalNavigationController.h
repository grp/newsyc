//
//  ModalNavigationController.h
//  newsyc
//
//  Created by Grant Paul on 3/22/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "NavigationController.h"

#import "BarButtonItem.h"

@interface ModalNavigationController : NavigationController <UINavigationControllerDelegate> {
    BarButtonItem *doneItem;
    UIViewController *currentController;
}

@end
