//
//  SearchController.h
//  newsyc
//
//  Created by Quin Hoxie on 6/2/11.
//

#import <UIKit/UIKit.h>
#import "HNAPISearch.h"

@interface SearchController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UISearchBar *searchBar;
	IBOutlet UISegmentedControl *facetControl;
	IBOutlet UITableView *tableView;
	BOOL searchPerformed;
	HNAPISearch *searchAPI;
	NSMutableArray *entries;
}

@property (nonatomic, retain) NSMutableArray *entries;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *facetControl;
@property (nonatomic) BOOL searchPerformed;

-(IBAction)textFieldReturn:(id)sender;
-(IBAction)backgroundTouched:(id)sender;
-(IBAction)facetSelected:(id)sender;
- (void)performSearch;

@end
