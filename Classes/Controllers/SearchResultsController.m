//
//  SearchResultsController.m
//  newsyc
//
//  Created by Quin Hoxie on 6/3/11.
//

#import "SearchResultsController.h"
#import "SubmissionTableCell.h"
#import "CommentListController.h"


@implementation SearchResultsController

@synthesize entries;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(receivedResults:) name:@"searchDone" object:nil];
}

-(void)receivedResults:(NSNotification *)notification {
	if ([notification userInfo] == nil){
		UIAlertView *alert = [[UIAlertView alloc] init];
		[alert setTitle:@"No Results"];
		[alert setMessage:@"Your search returned no results."];
		[alert addButtonWithTitle:@"Continue"];
		[alert setCancelButtonIndex:0];
		[alert show];
		[alert release];
	} else {
		NSDictionary *dict = [notification userInfo];
		self.entries = [dict objectForKey:@"array"];
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
    SubmissionTableCell *cell = (SubmissionTableCell *) [tableView dequeueReusableCellWithIdentifier:@"submission"];
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

#pragma mark -
#pragma mark Table view delegate

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	entries = nil;
	[super viewDidUnload];
}

- (void)dealloc {
    [super dealloc];
}


@end

