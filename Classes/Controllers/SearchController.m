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
#import "UIColor+Orange.h"
#import "AppDelegate.h"
#import "OrangeToolbar.h"
#import "EmptyView.h"

@implementation SearchController

- (id)initWithSession:(HNSession *)session_ {
    if ((self = [super init])) {
        session = [session_ retain];
    }

    return self;
}

- (void)loadView {
    [super loadView];

    tableView = [[UITableView alloc] initWithFrame:[[self view] bounds]];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [[self view] addSubview:tableView];

    searchBar = [[UISearchBar alloc] init];
    [searchBar sizeToFit];
    [searchBar setPlaceholder:@"Search"];
    [searchBar setFrame:CGRectMake(0, 0, [[self view] bounds].size.width, [searchBar bounds].size.height)];
    [searchBar setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth];
    [searchBar setDelegate:self];

    coloredView = [[OrangeToolbar alloc] initWithFrame:[searchBar bounds]];
    [[self view] addSubview:coloredView];
    
    facetControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Interesting", @"Recent", nil]];
    [facetControl setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth];
    [facetControl addTarget:self action:@selector(facetSelected:) forControlEvents:UIControlEventValueChanged];
    [facetControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [facetControl setSelectedSegmentIndex:0];
    [facetControl sizeToFit];
    [facetControl setFrame:CGRectMake(([coloredView bounds].size.height - [facetControl bounds].size.height) / 2, ([coloredView bounds].size.height - [facetControl bounds].size.height) / 2, [coloredView bounds].size.width - ((([coloredView bounds].size.height - [facetControl bounds].size.height) / 2) * 2), [facetControl bounds].size.height)];
    [coloredView addSubview:facetControl];

    indicator = [[LoadingIndicatorView alloc] initWithFrame:[tableView frame]];
    [indicator setBackgroundColor:[UIColor whiteColor]];
    [indicator setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [indicator setHidden:YES];
    [[self view] addSubview:indicator];
    
    emptyView = [[EmptyView alloc] initWithFrame:[tableView frame]];
    [emptyView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [emptyView setText:@"No Results"];
    [emptyView setBackgroundColor:[UIColor whiteColor]];
    [[self view] addSubview:emptyView];
}

- (HNAPISearch *)searchAPI {
	if (searchAPI == nil) {
		searchAPI = [[HNAPISearch alloc] initWithSession:session];
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
        
        [emptyView setHidden:YES];
        [indicator setHidden:NO];
    } else {
        [indicator setHidden:YES];
        [emptyView setHidden:NO];
    }
}

- (void)facetSelected:(id)sender {
	[searchBar resignFirstResponder];

	if ([facetControl selectedSegmentIndex] == 0) {
		[searchAPI setSearchType:kHNSearchTypeInteresting];
	} else {
		[searchAPI setSearchType:kHNSearchTypeRecent];
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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if ([self respondsToSelector:@selector(topLayoutGuide)] && [self respondsToSelector:@selector(bottomLayoutGuide)]) {
        [tableView setFrame:[[self view] bounds]];
        [coloredView setFrame:CGRectMake(0, [[self topLayoutGuide] length] - [searchBar bounds].size.height, [[self view] bounds].size.width, [searchBar bounds].size.height)];
    } else {
        [tableView setFrame:CGRectMake(0, [coloredView bounds].size.height, [[self view] bounds].size.width, [[self view] bounds].size.height - [coloredView bounds].size.height)];
        [coloredView setFrame:CGRectMake(0, 0, [[self view] bounds].size.width, [searchBar bounds].size.height)];
    }
}

- (void)receivedResults:(NSNotification *)notification {
    [indicator setHidden:YES];
    [emptyView setHidden:NO];
    
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
			[emptyView setHidden:YES];
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
    [[self navigationController] pushController:[controller autorelease] animated:YES];
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
    [emptyView release];
    emptyView = nil;
    [coloredView release];
    coloredView = nil;
    [indicator release];
    indicator = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    UIViewController *parentController = [[self navigationController] topViewController];
    UINavigationItem *navigationItem = [parentController navigationItem];
	[navigationItem setTitleView:searchBar];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    }

    [coloredView setOrange:![[NSUserDefaults standardUserDefaults] boolForKey:@"disable-orange"]];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disable-orange"]) {
        if ([coloredView respondsToSelector:@selector(setBarTintColor:)]) {
            [facetControl setTintColor:[UIColor whiteColor]];
        } else {
            [facetControl setTintColor:[UIColor mainOrangeColor]];
        }

        [searchBar setTintColor:[UIColor mainOrangeColor]];
    } else {
        [searchBar setTintColor:nil];
        [facetControl setTintColor:nil];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [searchBar resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

    UIViewController *parentController = [[self navigationController] topViewController];
    UINavigationItem *navigationItem = [parentController navigationItem];
	[navigationItem setTitleView:nil];
}

- (void)dealloc {
    [entries release];
    [searchBar release];
    [tableView release];
    [facetControl release];
    [emptyView release];
    [coloredView release];
    [searchAPI release];
    [indicator release];
    [session release];

    [super dealloc];
}

AUTOROTATION_FOR_PAD_ONLY

@end
