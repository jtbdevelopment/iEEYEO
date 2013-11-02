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
#import "ObservablesViewLayout.h"

//  TODO - add observable  ?
//  TODO - add search filter?
//  TODO - add student or class list

@implementation ObservablesViewController {
@private
    ObservationsViewController *_observationsViewController;
    NSFetchedResultsController *_fetchedResultsController;
    UICollectionView *_collectionView;
}

@synthesize observationsViewController = _observationsViewController;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize collectionView = _collectionView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if ([self tabBarItem]) {
            [[self tabBarItem] setTitle:[self name]];
        }
        [self.parentViewController setTitle:[self name]];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self collectionView] setCollectionViewLayout:[[ObservablesViewLayout alloc] init]];
    [self.collectionView registerClass:[ObservableViewCell class] forCellWithReuseIdentifier:OBSERVABLE_CELL];
    [self.parentViewController setTitle:[self name]];
    [self.collectionView setBackgroundColor:[Colors cream]];
    [[self collectionView] setDataSource:self];
    [[self collectionView] setDelegate:self];

//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addObservable:)];
//    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteObservable:)];
//    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editObservable:)];
//  TODO - make buttons work
//    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:addButton, editButton, deleteButton, nil];

    [UIView setAnimationsEnabled:NO];
    if (!_observationsViewController) {
        self.observationsViewController = [[ObservationsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        self.observationsViewController.managedObjectContext = [[EEYEOLocalDataStore instance] context];
    }
}

//- (void)addObservable:(id)sender {
//}

//- (void)deleteObservable:(id)sender {
//}

//- (void)editObservable:(id)sender {
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [_observationsViewController setObservable:[[self fetchedResultsController] objectAtIndexPath:indexPath]];
    [[self navigationController] pushViewController:_observationsViewController animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger i = [[[[self fetchedResultsController] sections] objectAtIndex:section] numberOfObjects];
    return i;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ObservableViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:OBSERVABLE_CELL forIndexPath:indexPath];
    EEYEOObservable *observable = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [cell setObservable:observable];
    return cell;
}

- (NSArray *)sortDescriptors {
    return nil;
}

- (NSString * const)entityType {
    return nil;
}

- (NSString *)name {
    return @"Fred";

}

//  TODO - should this be here?  Or add to dao?
- (NSFetchedResultsController *)fetchedResultsController {
    @synchronized (self) {
        if (_fetchedResultsController != nil) {
            return _fetchedResultsController;
        }

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

        [fetchRequest setFetchBatchSize:20];

        NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityType] inManagedObjectContext:[[EEYEOLocalDataStore instance] context]];
        [fetchRequest setEntity:entity];

        NSArray *sortDescriptors = [self sortDescriptors];
        [fetchRequest setSortDescriptors:sortDescriptors];

        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[EEYEOLocalDataStore instance] context] sectionNameKeyPath:nil cacheName:nil];
        [_fetchedResultsController setDelegate:self];

        NSError *error = nil;
        if (![_fetchedResultsController performFetch:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }

    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[self collectionView] reloadData];
}

@end
