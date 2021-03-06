//
//  CategoryPickerViewController.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "CategoryPickerViewController.h"
#import "EEYEOLocalDataStore.h"
#import "EEYEOObservationCategory.h"
#import "Colors.h"
#import "EEYEOObjectTableCell.h"

@interface CategoryPickerViewController ()
- (void)configureCell:(EEYEOObjectTableCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation CategoryPickerViewController {
@private
    NSMutableSet *_selectedCategories;
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *_managedObjectContext;
}

@synthesize selectedCategories = _selectedCategories;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[EEYEOObjectTableCell class] forCellReuseIdentifier:CATEGORY_CELL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EEYEOObjectTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CATEGORY_CELL];

    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EEYEOObjectTableCell *cell = (EEYEOObjectTableCell *) [tableView cellForRowAtIndexPath:indexPath];

    EEYEOObservationCategory *category = (EEYEOObservationCategory *) cell.object;
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [_selectedCategories removeObject:category];
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [_selectedCategories addObject:category];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:CATEGORYENTITY inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"shortName" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];

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

- (void)configureCell:(EEYEOObjectTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    EEYEOObservationCategory *category = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell setObject:category];
    cell.detailTextLabel.text = [category desc];
    cell.textLabel.text = [category shortName];
    cell.selectedBackgroundView.backgroundColor = [Colors forestGreen];
    if ([_selectedCategories containsObject:category]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}
@end
