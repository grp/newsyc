//
//  SearchController.m
//  newsyc
//
//  Created by Quin Hoxie on 6/2/11.
//

#import "SearchController.h"
#import "SubmissionTableCell.h"
#import "CommentListController.h"
#import "LoadingIndicatorView.h"

@implementation SearchController

@synthesize searchBar;
@synthesize facetControl;
@synthesize tableView;
@synthesize emptyResultsView;
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
    if ([[searchBar text] length] > 0) {
        self.searchPerformed = YES;
        [[self searchAPI] performSearch:[searchBar text]];
    
        [emptyResultsView setHidden:YES];
        [indicator setHidden:NO];
    } else {
        [indicator setHidden:YES];
        [emptyResultsView setHidden:NO];
    }
}

- (void)searchBarSearchButtonClicked:(id)sender {
	[searchBar resignFirstResponder];
	[self performSearch];
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    // This is a hack, but it's all that's available right now.
    UITextField *searchBarTextField = nil;
    for (UIView *subview in [searchBar subviews]) {
        if ([subview isKindOfClass:[UITextField class]]) {
            searchBarTextField = (UITextField *)subview;
            break;
        }
    }
    [searchBarTextField setEnablesReturnKeyAutomatically:NO];
    
    indicator = [[LoadingIndicatorView alloc] initWithFrame:[tableView frame]];
    [indicator setBackgroundColor:[UIColor whiteColor]];
    [indicator setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:indicator];
    [indicator setHidden:YES];
    
    [emptyResultsView setFrame:[tableView frame]];
    
	self.searchPerformed = NO;
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(receivedResults:) name:@"searchDone" object:nil];
}

- (void)receivedResults:(NSNotification *)notification {
    [indicator setHidden:YES];
    [emptyResultsView setHidden:NO];
    
	if ([notification userInfo] == nil) {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Unable to Connect"
							  message:@"Could not connect to search server. Please try again."
							  delegate:nil
							  cancelButtonTitle:@"Continue"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		NSDictionary *dict = [notification userInfo];
		self.entries = [dict objectForKey:@"array"];
        
		if ([entries count] != 0) {
			[emptyResultsView setHidden:YES];
            [[self tableView] setContentOffset:CGPointZero animated:NO];
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

- (void)viewDidUnload {
    [super viewDidUnload];
	self.entries = nil;
    self.searchBar = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	[[self navigationController] setNavigationBarHidden:YES animated:animated];
    
    [[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated:YES];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disable-orange"]) {
        [searchBar setTintColor:[UIColor colorWithRed:1.0f green:0.4f blue:0.0f alpha:1.0f]];
        [facetControl setTintColor:[UIColor colorWithRed:1.0f green:0.4f blue:0.0f alpha:1.0f]];
        [coloredView setBackgroundColor:[UIColor colorWithRed:(255.0f / 236.0f) green:(255.0f / 141.0f) blue:(255.0f / 91.0f) alpha:1.0f]];
    } else {
        [searchBar setTintColor:nil];
        [facetControl setTintColor:nil];
        [coloredView setBackgroundColor:[UIColor colorWithRed:(255.0f / 170.0f) green:(255.0f / 180.0f) blue:(255.0f / 190.0f) alpha:1.0f]];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[self navigationController] setNavigationBarHidden:NO animated:animated];
}

- (void)dealloc {
	[searchAPI release];
	[emptyResultsView release];
    [super dealloc];
}

@end
