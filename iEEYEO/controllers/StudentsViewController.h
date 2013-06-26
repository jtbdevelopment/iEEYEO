//
//  StudentsViewController.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ObservationsViewController;

static NSString *const STUDENT_CELL = @"StudentCell";

@interface StudentsViewController : UICollectionViewController <NSFetchedResultsControllerDelegate>

@property(strong, nonatomic) ObservationsViewController *observationsViewController;
@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
