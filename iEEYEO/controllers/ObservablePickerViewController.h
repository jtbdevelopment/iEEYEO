//
//  ObservablePickerViewController.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ObservablePickerViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, NSFetchedResultsControllerDelegate>

@property(nonatomic, strong) IBOutlet UIPickerView *pickerField;
@property(nonatomic, strong) NSMutableArray *observable;  //  TODO - array of 1, do better
@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
