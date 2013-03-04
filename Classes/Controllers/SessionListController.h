//
//  SessionListController.h
//  newsyc
//
//  Created by Grant Paul on 1/8/13.
//
//

#import <HNKit/HNKit.h>

#import "NavigationController.h"

@interface SessionListController : UIViewController <UITableViewDelegate, UITableViewDataSource, NavigationControllerLoginDelegate> {
    NSArray *sessions;
    HNSession *automaticDisplaySession;

    UITableView *tableView;
    BarButtonItem *editBarButtonItem;
    BarButtonItem *doneBarButtonItem;
    BarButtonItem *addBarButtonItem;
}

@property (nonatomic, retain) HNSession *automaticDisplaySession;

@end
