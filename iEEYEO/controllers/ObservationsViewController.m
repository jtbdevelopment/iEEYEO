//
//  ObservationsViewController.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "ObservationsViewController.h"
#import "EEYEOStudent.h"
#import "EEYEOLocalDataStore.h"
#import "EEYEOObservation.h"
#import "Colors.h"
#import "ObservationViewController.h"
#import "NSDateWithMillis.h"

@interface ObservationsViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

//  TODO - highlight color?
//  TODO - search filter?
@implementation ObservationsViewController {
@private
    EEYEOObservable *_observable;
    NSDateFormatter *_dateFormatter;
    ObservationViewController *_observationView;
}

@synthesize observable = _observable;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        //  TODO - central
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        _observationView = [[ObservationViewController alloc] init];
    }
    return self;
}

- (void)setObservable:(EEYEOStudent *)observable {
    _observable = observable;
    _fetchedResultsController = nil;
    [[self tableView] reloadData];
    [[self navigationItem] setTitle:[_observable desc]];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addObservation:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.editButtonItem, addButton, nil];

    self.tableView.backgroundColor = [Colors cream];
    self.tableView.separatorColor = [Colors darkBrown];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addObservation:(id)sender {
    EEYEOObservation *newObservation = [[EEYEOLocalDataStore instance] create:OBSERVATIONENTITY];
    [newObservation setObservable:_observable];
    [newObservation setAppUser:[[EEYEOLocalDataStore instance] appUser]];
    [newObservation setObservationTimestampFromNSDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    [newObservation setModificationTimestampFromNSDateWithMillis:[NSDateWithMillis dateWithTimeIntervalFromNow:0]];
    [_observationView setObservation:newObservation];
    [_observationView setManagedObjectContext:_managedObjectContext];
    [_observationView setNewObservation:YES];
    [self.navigationController pushViewController:_observationView animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EEYEOObservation *observation = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[EEYEOLocalDataStore instance] deleteFromLocalStore:observation];
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [Colors cream];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EEYEOObservation *observation = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [_observationView setObservation:observation];
    [_observationView setManagedObjectContext:_managedObjectContext];
    [_observationView setNewObservation:NO];
    [self.navigationController pushViewController:_observationView animated:YES];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:OBSERVATIONENTITY inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    NSSortDescriptor *sortDescriptorOTS = [[NSSortDescriptor alloc] initWithKey:@"observationTimestamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptorOTS];
    [fetchRequest setSortDescriptors:sortDescriptors];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"observable.id = %@", [[self observable] id]];
    [fetchRequest setPredicate:predicate];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    EEYEOObservation *observation = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.detailTextLabel.text = [_dateFormatter stringFromDate:[observation observationTimestampToNSDate]];
    cell.textLabel.text = [observation comment];
    cell.selectedBackgroundView.backgroundColor = [Colors forestGreen];
}

@end
