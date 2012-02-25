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

- (void)loadView {
    [super loadView];
    
    searchBar = [[UISearchBar alloc] init];
    [searchBar sizeToFit];
    [searchBar setPlaceholder:@"Search Hacker News"];
    [searchBar setFrame:CGRectMake(0, 0, [[self view] bounds].size.width, [searchBar bounds].size.height)];
    [searchBar setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth];
    [searchBar setDelegate:self];
    [[self view] addSubview:searchBar];
    
    coloredView = [[UIView alloc] initWithFrame:CGRectMake(0, [searchBar bounds].size.height, [[self view] bounds].size.width, [searchBar bounds].size.height)];
    [coloredView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth];
    [[self view] addSubview:coloredView];
    
    facetControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Interesting", @"Recent", nil]];
    [facetControl addTarget:self action:@selector(facetSelected:) forControlEvents:UIControlEventValueChanged];
    [facetControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [facetControl setSelectedSegmentIndex:0];
    [facetControl sizeToFit];
    [facetControl setFrame:CGRectMake(([coloredView bounds].size.height - [facetControl bounds].size.height) / 2, ([coloredView bounds].size.height - [facetControl bounds].size.height) / 2, [coloredView bounds].size.width - ((([coloredView bounds].size.height - [facetControl bounds].size.height) / 2) * 2), [facetControl bounds].size.height)];
    [coloredView addSubview:facetControl];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, [searchBar bounds].size.height + [coloredView bounds].size.height, [[self view] bounds].size.width, [[self view] bounds].size.height - [searchBar bounds].size.height - [coloredView bounds].size.height)];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [[self view] addSubview:tableView];
    
    indicator = [[LoadingIndicatorView alloc] initWithFrame:[tableView frame]];
    [indicator setBackgroundColor:[UIColor whiteColor]];
    [indicator setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [indicator setHidden:YES];
    [[self view] addSubview:indicator];
    
    emptyResultsView = [[UILabel alloc] initWithFrame:[tableView frame]];
    [emptyResultsView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [emptyResultsView setText:@"No Results"];
    [emptyResultsView setTextAlignment:UITextAlignmentCenter];
    [emptyResultsView setFont:[UIFont systemFontOfSize:17.0f]];
    [emptyResultsView setTextColor:[UIColor grayColor]];
    [emptyResultsView setFrame:[tableView frame]];
    [[self view] addSubview:emptyResultsView];
}

- (HNAPISearch *)searchAPI {
	if (!searchAPI) {
		searchAPI = [[HNAPISearch alloc] init];
	}
	return searchAPI;
}

- (void)backgroundTouched:(id)sender {
	[searchBar resignFirstResponder];
}

- (void)performSearch {
    if ([[searchBar text] length] > 0) {
        searchPerformed = YES;
        [[self searchAPI] performSearch:[searchBar text]];
        
        [emptyResultsView setHidden:YES];
        [indicator setHidden:NO];
    } else {
        [indicator setHidden:YES];
        [emptyResultsView setHidden:NO];
    }
}

- (void)facetSelected:(id)sender {
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
        
	searchPerformed = NO;
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
        [entries release];
		entries = [[dict objectForKey:@"array"] retain];
        
		if ([entries count] != 0) {
			[emptyResultsView setHidden:YES];
            [tableView setContentOffset:CGPointZero animated:NO];
		}

        [tableView reloadData];
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

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SubmissionTableCell *cell = (SubmissionTableCell *) [tableView dequeueReusableCellWithIdentifier:@"submission"];
    if (cell == nil) cell = [[[SubmissionTableCell alloc] initWithReuseIdentifier:@"submission"] autorelease];
    HNEntry *entry = [entries objectAtIndex:[indexPath row]];
    [cell setSubmission:entry];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HNEntry *entry = [entries objectAtIndex:[indexPath row]];
    
    CommentListController *controller = [[CommentListController alloc] initWithSource:entry];
    [[self navigationController] pushViewController:[controller autorelease] animated:YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [entries release];
    entries = nil;
    [searchBar release];
    searchBar = nil;
    [tableView release];
    tableView = nil;
    [facetControl release];
    facetControl = nil;
    [emptyResultsView release];
    emptyResultsView = nil;
    [coloredView release];
    coloredView = nil;
    [indicator release];
    indicator = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	[[self navigationController] setNavigationBarHidden:YES animated:animated];
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disable-orange"]) {
        [searchBar setTintColor:[UIColor colorWithRed:1.0f green:0.4f blue:0.0f alpha:1.0f]];
        [facetControl setTintColor:[UIColor colorWithRed:1.0f green:0.4f blue:0.0f alpha:1.0f]];
        [coloredView setBackgroundColor:[UIColor colorWithRed:(236.0f / 255.0f) green:(141.0f / 255.0f) blue:(91.0f / 255.0f) alpha:1.0f]];
    } else {
        [searchBar setTintColor:nil];
        [facetControl setTintColor:nil];
        [coloredView setBackgroundColor:[UIColor colorWithRed:(170.0f / 255.0f) green:(180.0f / 255.0f) blue:(190.0f / 255.0f) alpha:1.0f]];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [searchBar resignFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    
	[[self navigationController] setNavigationBarHidden:NO animated:animated];
}

- (void)dealloc {
    [entries release];
    [searchBar release];
    [tableView release];
    [facetControl release];
    [emptyResultsView release];
    [coloredView release];
    [searchAPI release];
    [indicator release];

    [super dealloc];
}

@end
