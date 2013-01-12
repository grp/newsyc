//
//  SessionListController.m
//  newsyc
//
//  Created by Grant Paul on 1/8/13.
//
//

#import "SessionListController.h"
#import "MainTabBarController.h"
#import "BarButtonItem.h"
#import "AppDelegate.h"
#import "HackerNewsLoginController.h"
#import "ModalNavigationController.h"

@implementation SessionListController
@synthesize automaticDisplaySession;

#pragma mark - Lifecycle

- (id)init {
    if ((self = [super init])) {
        [self setTitle:@"Sessions"];
    }

    return self;
}

- (void)loadView {
    [super loadView];

    tableView = [[UITableView alloc] initWithFrame:[[self view] bounds]];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setRowHeight:64.0f];
    [[self view] addSubview:tableView];

    addBarButtonItem = [[BarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSessionFromBarButtonItem:)];
    editBarButtonItem = [[BarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editFromBarButtonItem:)];
    doneBarButtonItem = [[BarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneFromBarButtonItem:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[self navigationItem] setRightBarButtonItem:addBarButtonItem];
    [[self navigationItem] setLeftBarButtonItem:editBarButtonItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self clearRightControllerIfNecessary];

    NSIndexPath *selectedIndexPath = [tableView indexPathForSelectedRow];
    HNSession *session = nil;

    if (selectedIndexPath != nil) {
        session = [self sessionAtIndexPath:selectedIndexPath];
    }

    [self reloadSessions];
    [tableView reloadData];

    if (selectedIndexPath != nil) {
        NSIndexPath *newIndexPath = [self indexPathForSession:session];

        if (newIndexPath != nil) {
            [tableView selectRowAtIndexPath:newIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [tableView deselectRowAtIndexPath:newIndexPath animated:YES];
        }
    }

    if (!animated) {
        [self pushAutomaticDisplaySesssionAnimated:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (animated) {
        [self pushAutomaticDisplaySesssionAnimated:animated];
    }

    [[HNSessionController sessionController] setRecentSession:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if ([tableView isEditing]) {
        [tableView setEditing:NO animated:NO];
        [[self navigationItem] setLeftBarButtonItem:editBarButtonItem];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];

    [tableView release];
    tableView = nil;
    [sessions release];
    sessions = nil;
    [editBarButtonItem release];
    editBarButtonItem = nil;
    [doneBarButtonItem release];
    doneBarButtonItem = nil;
    [addBarButtonItem release];
    addBarButtonItem = nil;
}

- (void)dealloc {
    [tableView release];
    [sessions release];
    [automaticDisplaySession release];

    [super dealloc];
}

#pragma mark - Sessions

- (void)reloadSessions {
    [sessions release];
    sessions = [[[HNSessionController sessionController] sessions] retain];
}

- (void)clearRightControllerIfNecessary {
    EmptyController *emptyController = [[EmptyController alloc] init];
    [[self navigationController] pushController:emptyController animated:NO];
    [EmptyController release];
}

- (void)pushMainControllerForSession:(HNSession *)session animated:(BOOL)animated {
    [[HNSessionController sessionController] setRecentSession:session];

    NSIndexPath *indexPath = [self indexPathForSession:session];
    if (indexPath != nil) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }

    MainTabBarController *tabBarController = [[MainTabBarController alloc] initWithSession:session];
    
    BOOL hideBackButton = [session isAnonymous] || ([sessions count] == 1);
    [[tabBarController navigationItem] setHidesBackButton:hideBackButton];
    
    [[self navigationController] pushController:tabBarController animated:animated];
    [tabBarController release];

    if (!animated) {
        // If we aren't animated, we are expecting the controller to be pushed
        // instantly. However, UINavigationController takes a run loop iteration
        // to actually perform the push, so let that happen before we return.
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
    }
}

- (void)pushAnonymousSessionIfNecessaryAnimated:(BOOL)animated {
    if ([sessions count] == 0) {
        HNAnonymousSession *anonymousSession = [[HNAnonymousSession alloc] init];
        [self pushMainControllerForSession:anonymousSession animated:animated];
        [anonymousSession release];
    }
}

- (void)pushAutomaticDisplaySesssionAnimated:(BOOL)animated {
    if (automaticDisplaySession != nil) {
        [self pushMainControllerForSession:automaticDisplaySession animated:animated];
        [automaticDisplaySession release];
        automaticDisplaySession = nil;
    } else {
        [self pushAnonymousSessionIfNecessaryAnimated:animated];
    }
}

#pragma mark - Bar Button Items

- (void)editFromBarButtonItem:(BarButtonItem *)barButtonItem {
    [tableView setEditing:YES animated:YES];
    [[self navigationItem] setLeftBarButtonItem:doneBarButtonItem animated:YES];
}

- (void)doneFromBarButtonItem:(BarButtonItem *)barButtonItem {
    [tableView setEditing:NO animated:YES];
    [[self navigationItem] setLeftBarButtonItem:editBarButtonItem animated:YES];
}

- (void)navigationController:(NavigationController *)navigationController didLoginWithSession:(HNSession *)session {
    if ([navigationController topViewController] != self) {
        [self setAutomaticDisplaySession:session];
        [[self navigationController] popToViewController:self animated:YES];
    } else {
        [self pushMainControllerForSession:session animated:YES];
    }
}

- (void)navigationControllerRequestedSessions:(NavigationController *)navigationController {
    [[self navigationController] popToViewController:self animated:YES];
}

- (void)addSessionFromBarButtonItem:(BarButtonItem *)barButtonItem {
    [[self navigationController] requestLogin];
}

#pragma mark - Table View

- (HNSession *)sessionAtIndexPath:(NSIndexPath *)indexPath {
    return [sessions objectAtIndex:[indexPath row]];
}

- (NSIndexPath *)indexPathForSession:(HNSession *)session {
    NSInteger index = [sessions indexOfObject:session];

    if (index == NSNotFound) {
        return nil;
    } else {
        return [NSIndexPath indexPathForRow:index inSection:0];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [sessions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (cell == nil) cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"] autorelease];

    HNSession *session = [self sessionAtIndexPath:indexPath];
    [[cell textLabel] setText:[[session user] identifier]];

    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HNSession *session = [self sessionAtIndexPath:indexPath];
    [self pushMainControllerForSession:session animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView_ moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    HNSession *session = [self sessionAtIndexPath:sourceIndexPath];
    [[HNSessionController sessionController] moveSession:session toIndex:[destinationIndexPath row]];
    [self reloadSessions];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView_ commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];

        HNSession *session = [self sessionAtIndexPath:indexPath];
        [[HNSessionController sessionController] removeSession:session];
        [self reloadSessions];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

        [tableView endUpdates];

        [self pushAnonymousSessionIfNecessaryAnimated:YES];
    }
}

@end
