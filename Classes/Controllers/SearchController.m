//
//  SearchController.m
//  newsyc
//
//  Created by Quin Hoxie on 6/2/11.
//

#import "SearchController.h"
#import "SubmissionTableCell.h"
#import "CommentListController.h"

@implementation SearchController

@synthesize searchBar;
@synthesize facetControl;
@synthesize tableView;
@synthesize entries;
@synthesize searchPerformed;

- (HNAPISearch *)searchAPI {
	if (!searchAPI) {
		searchAPI = [[HNAPISearch alloc] init];
	}
	return searchAPI;
}

- (IBAction)backgroundTouched:(id)sender {
	[searchBar resignFirstResponder];
}

- (IBAction)facetSelected:(id)sender {
	[searchBar resignFirstResponder];

	if (facetControl.selectedSegmentIndex == 0) {
		searchAPI.searchType = kHNSearchTypeInteresting;
	} else {
		searchAPI.searchType = kHNSearchTypeRecent;
	}
	if (searchPerformed) {
		[self performSearch];
	}
}

- (void)performSearch {
	self.searchPerformed = YES;
	[[self searchAPI] performSearch:[searchBar text]];
}

- (void)searchBarSearchButtonClicked:(id)sender {
	[searchBar resignFirstResponder];
	[self performSearch];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.searchPerformed = NO;
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(receivedResults:) name:@"searchDone" object:nil];
}

- (void)receivedResults:(NSNotification *)notification {
	if ([notification userInfo] == nil) {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Error"
							  message:@"Could not connect to search server. Please try again."
							  delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		NSDictionary *dict = [notification userInfo];
		self.entries = [dict objectForKey:@"array"];
		if ([entries count] == 0) {
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@"No Results"
								  message:@"Sorry, but your search returned no results."
								  delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
        [[self tableView] reloadData];
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [entries count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HNEntry *entry = [entries objectAtIndex:[indexPath row]];
    return [SubmissionTableCell heightForEntry:entry withWidth:[[self view] bounds].size.width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SubmissionTableCell *cell = (SubmissionTableCell *) [[self tableView] dequeueReusableCellWithIdentifier:@"submission"];
    if (cell == nil) cell = [[[SubmissionTableCell alloc] initWithReuseIdentifier:@"submission"] autorelease];
    HNEntry *entry = [entries objectAtIndex:[indexPath row]];
    [cell setSubmission:entry];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HNEntry *entry = [entries objectAtIndex:[indexPath row]];
    CommentListController *controller = [[CommentListController alloc] initWithSource:entry];
    [controller setTitle:@"Submission"];
    [[self navigationController] pushViewController:[controller autorelease] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.entries = nil;
    self.searchBar = nil;
}

- (void)dealloc {
	[searchAPI release];
    [super dealloc];
}

@end
