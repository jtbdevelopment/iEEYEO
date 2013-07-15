//
//  StudentsViewController.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "StudentsViewController.h"
#import "EEYEOLocalDataStore.h"
#import "StudentsViewCell.h"
#import "EEYEOStudent.h"
#import "ObservationsViewController.h"
#import "Colors.h"

@interface StudentsViewController ()
- (void)configureCell:(StudentsViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end


//  TODO - show classlists?
//  TODO - add student  ?
//  TODO - add search filter?

@implementation StudentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[StudentsViewCell class] forCellWithReuseIdentifier:STUDENT_CELL];
    [self setClearsSelectionOnViewWillAppear:NO];
    [self setTitle:@"iE-EYE-O"];
    [self.collectionView setBackgroundColor:[Colors cream]];
    [UIView setAnimationsEnabled:NO];
    //  TODO - probably in init or alloc
    if (!_observationsViewController) {
        self.observationsViewController = [[ObservationsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        self.observationsViewController.managedObjectContext = self.managedObjectContext;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    StudentsViewCell *cell = (StudentsViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    [cell setHighlighted:NO];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    StudentsViewCell *cell = (StudentsViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    [cell setHighlighted:YES];
    [_observationsViewController setStudent:[_fetchedResultsController objectAtIndexPath:indexPath]];
    [[self navigationController] pushViewController:_observationsViewController animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    StudentsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:STUDENT_CELL forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)configureCell:(StudentsViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    EEYEOStudent *student = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.first.text = [student firstName];
    if (student.lastName) {
        cell.last.text = [student lastName];
    } else {
        cell.last.text = @"";
    }
}

//  TODO - should this be here?  Or add to dao?
- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:STUDENTENTITY inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    // Edit the sort key as appropriate.
    //  TODO - const the fields
    NSSortDescriptor *sortDescriptorFN = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *sortDescriptorLN = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptorFN, sortDescriptorLN];

    [fetchRequest setSortDescriptors:sortDescriptors];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
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
    [self.collectionView reloadData];
}

@end
