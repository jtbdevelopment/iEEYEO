//
//  ObservablesViewController.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "ObservablesViewController.h"
#import "EEYEOLocalDataStore.h"
#import "ObservableViewCell.h"
#import "EEYEOStudent.h"
#import "ObservationsViewController.h"
#import "Colors.h"

@interface ObservablesViewController ()
- (void)configureCell:(ObservableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end


//  TODO - show classlists?
//  TODO - add observable  ?
//  TODO - add search filter?

@implementation ObservablesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[ObservableViewCell class] forCellWithReuseIdentifier:OBSERVABLE_CELL];
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
    ObservableViewCell *cell = (ObservableViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    [cell setHighlighted:NO];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ObservableViewCell *cell = (ObservableViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    [cell setHighlighted:YES];
    [_observationsViewController setObservable:[_fetchedResultsController objectAtIndexPath:indexPath]];
    [[self navigationController] pushViewController:_observationsViewController animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ObservableViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:OBSERVABLE_CELL forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)configureCell:(ObservableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    EEYEOObservable *observable = [self.fetchedResultsController objectAtIndexPath:indexPath];

    [cell setObservable:observable];
}

//  TODO - should this be here?  Or add to dao?
- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:STUDENTENTITY inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    [fetchRequest setFetchBatchSize:20];

    //  TODO - better sort
    NSSortDescriptor *sortDescriptorFN = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *sortDescriptorLN = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptorFN, sortDescriptorLN];

    [fetchRequest setSortDescriptors:sortDescriptors];

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
    [self.collectionView reloadData];
}

@end
