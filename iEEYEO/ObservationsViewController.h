//
//  ObservationsViewController.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EEYEOStudent;

@interface ObservationsViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property(nonatomic, strong) EEYEOStudent *student;
@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
