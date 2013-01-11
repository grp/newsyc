//
//  SearchController.h
//  newsyc
//
//  Created by Quin Hoxie on 6/2/11.
//

#import "HNAPISearch.h"

@class LoadingIndicatorView;

@interface SearchController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    HNSession *session;
    HNAPISearch *searchAPI;
    NSMutableArray *entries;

    UISearchBar *searchBar;
    UINavigationBar *coloredView;
    UISegmentedControl *facetControl;
    
	UITableView *tableView;
	UILabel *emptyResultsView;
    LoadingIndicatorView *indicator;
	BOOL searchPerformed;
}

- (id)initWithSession:(HNSession *)session_;

@end
