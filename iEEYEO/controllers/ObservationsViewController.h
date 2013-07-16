//
//  ObservationsViewController.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EEYEOObservable;

@interface ObservationsViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property(nonatomic, strong) EEYEOObservable *observable;
@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)setObservable:(EEYEOObservable *)observable;

@end
