//
//  ObservablePickerViewController.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EEYEOObservation;

@interface CopyObservationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *observable;  //  TODO - array of 1, do better
@property(strong, nonatomic) EEYEOObservation *observation;
@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
