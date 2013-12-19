//
//  ObservablePickerViewController.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "CopyObservationViewController.h"
#import "EEYEOLocalDataStore.h"
#import "EEYEOObservable.h"
#import "CategoryPickerViewController.h"
#import "EEYEOObjectTableCell.h"
#import "Colors.h"
#import "EEYEOObservation.h"
#import "EEYEOPhoto.h"

@interface CopyObservationViewController ()

@end

@implementation CopyObservationViewController {
@private
    UITableView *_tableView;
    NSMutableArray *_observable;
    NSMutableSet *_selectedObservables;
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *_managedObjectContext;
    EEYEOObservation *_observation;
}

@synthesize tableView = _tableView;
@synthesize observable = _observable;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;

@synthesize observation = _observation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _selectedObservables = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    doneButton.title = @"Copy";
    [[self navigationItem] setRightBarButtonItems:[NSArray arrayWithObjects:doneButton, nil] animated:YES];
    [self.tableView registerClass:[EEYEOObjectTableCell class] forCellReuseIdentifier:CATEGORY_CELL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)done:(id)sender {
    //  Easy clone
    NSMutableDictionary *obsDictionary = [[NSMutableDictionary alloc] init];
    [_observation writeToDictionary:obsDictionary];
    [obsDictionary setObject:@"" forKey:JSON_ID];
    NSMutableArray *photoDictionaries = [[NSMutableArray alloc] init];
    for (EEYEOPhoto *photo in [_observation photos]) {
        NSMutableDictionary *photoDictionary = [[NSMutableDictionary alloc] init];
        [photo writeToDictionary:photoDictionary];
        [photoDictionary setObject:@"" forKey:JSON_ID];
        [photoDictionaries addObject:photoDictionary];
    }
    for (EEYEOObservable *observable in _selectedObservables) {
        EEYEOObservation *copy = [[EEYEOLocalDataStore instance] create:OBSERVATIONENTITY];
        [copy loadFromDictionary:obsDictionary];
        [copy setObservable:observable];
        [[EEYEOLocalDataStore instance] saveToLocalStore:copy];
        for (NSMutableDictionary *photoDictionary in photoDictionaries) {
            EEYEOPhoto *photoCopy = [[EEYEOLocalDataStore instance] create:PHOTOENTITY];
            [photoCopy loadFromDictionary:photoDictionary];
            [photoCopy setPhotoFor:copy];
            [photoCopy setImageFromImage:[photoCopy image]];
            [[EEYEOLocalDataStore instance] saveToLocalStore:photoCopy];
        }
    }
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EEYEOObjectTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CATEGORY_CELL];
    EEYEOObservable *observable = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell setObject:observable];
    cell.detailTextLabel.text = [observable desc];
    cell.textLabel.text = [observable desc];
    cell.selectedBackgroundView.backgroundColor = [Colors forestGreen];
    if ([_selectedObservables containsObject:observable]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EEYEOObjectTableCell *cell = (EEYEOObjectTableCell *) [tableView cellForRowAtIndexPath:indexPath];

    EEYEOObservable *observable = (EEYEOObservable *) cell.object;
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [_selectedObservables removeObject:observable];
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [_selectedObservables addObject:observable];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:OBSERVABLEENTITY inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    NSSortDescriptor *sortDescriptorOTS = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptorOTS];
    [fetchRequest setSortDescriptors:sortDescriptors];

    NSPredicate *idNot = [NSPredicate predicateWithFormat:@"self != %@", [(EEYEOIdObject *) [_observable objectAtIndex:0] objectID]];
    [fetchRequest setPredicate:idNot];
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
    [self.tableView reloadData];
}

@end
