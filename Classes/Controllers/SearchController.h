//
//  SearchController.h
//  newsyc
//
//  Created by Quin Hoxie on 6/2/11.
//

#import "HNAPISearch.h"

@class LoadingIndicatorView;

@interface SearchController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    UISearchBar *searchBar;
    UISegmentedControl *facetControl;
	UITableView *tableView;
	UILabel *emptyResultsView;
    UIView *coloredView;
    LoadingIndicatorView *indicator;
	BOOL searchPerformed;
	HNAPISearch *searchAPI;
	NSMutableArray *entries;
}

@end
