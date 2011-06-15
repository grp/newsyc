//
//  SearchController.m
//  newsyc
//
//  Created by Quin Hoxie on 6/2/11.
//

#import "SearchController.h"
#import "SearchResultsController.h"

@implementation SearchController

@synthesize searchButton;
@synthesize searchQuery;
@synthesize facetControl;

- (HNAPISearch *)searchAPI {
	if (!searchAPI) {
		searchAPI = [[HNAPISearch alloc] init];
	}
	return searchAPI;
}

- (IBAction)performSearch:(id)sender {
	[[self searchAPI] performSearch:[searchQuery text]];

	SearchResultsController *viewController = [[SearchResultsController alloc] initWithNibName:@"SearchResultsController" bundle:[NSBundle mainBundle]];

	viewController.entries = [[self searchAPI] entries];

	[viewController setTitle:@"Search Results"];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
    viewController = nil;
}

- (IBAction)textFieldReturn:(id)sender {
	[sender resignFirstResponder];
}

- (IBAction)backgroundTouched:(id)sender {
	[searchQuery resignFirstResponder];
}

- (IBAction)facetSelected:(id)sender {
	if (facetControl.selectedSegmentIndex == 0) {
		searchAPI.searchType = kHNSearchTypeInteresting;
	} else {
		searchAPI.searchType = kHNSearchTypeRecent;
	}
}

- (void)viewDidLoad {
	[self.navigationController.parentViewController setTitle:@"Hacker News"];
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.searchButton = nil;
	self.searchQuery = nil;
}

- (void)dealloc {
	[searchAPI release];
    [super dealloc];
}

@end
