//
//  EEYEOMasterViewController.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EEYEODetailViewController;

#import <CoreData/CoreData.h>

@interface EEYEOMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property(strong, nonatomic) EEYEODetailViewController *detailViewController;

@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end