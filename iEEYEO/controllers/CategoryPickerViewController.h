//
//  CategoryPickerViewController.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryPickerViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property(strong, nonatomic) NSMutableSet *selectedCategories;
@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
