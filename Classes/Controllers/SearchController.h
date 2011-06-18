//
//  SearchController.h
//  newsyc
//
//  Created by Quin Hoxie on 6/2/11.
//

#import "HNAPISearch.h"

@class LoadingIndicatorView;

@interface SearchController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UISearchBar *searchBar;
	IBOutlet UISegmentedControl *facetControl;
	IBOutlet UITableView *tableView;
	IBOutlet UIView *emptyResultsView;
    LoadingIndicatorView *indicator;
	BOOL searchPerformed;
	HNAPISearch *searchAPI;
	NSMutableArray *entries;
}

@property (nonatomic, retain) NSMutableArray *entries;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *facetControl;
@property (nonatomic, retain) IBOutlet UIView *emptyResultsView;
@property (nonatomic) BOOL searchPerformed;

- (IBAction)backgroundTouched:(id)sender;
- (IBAction)facetSelected:(id)sender;
- (void)performSearch;

@end
