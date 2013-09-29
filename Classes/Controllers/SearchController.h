//
//  SearchController.h
//  newsyc
//
//  Created by Quin Hoxie on 6/2/11.
//

#import <HNKit/HNAPISearch.h>

@class EmptyView;
@class OrangeToolbar;
@class LoadingIndicatorView;

@interface SearchController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    HNSession *session;
    HNAPISearch *searchAPI;
    NSMutableArray *entries;

    UISearchBar *searchBar;
    OrangeToolbar *coloredView;
    UISegmentedControl *facetControl;
    
	UITableView *tableView;
	EmptyView *emptyView;
    LoadingIndicatorView *indicator;
	BOOL searchPerformed;
}

- (id)initWithSession:(HNSession *)session_;

@end
