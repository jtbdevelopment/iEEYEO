//
//  ObservablesViewController.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ObservationsViewController;

static NSString *const OBSERVABLE_CELL = @"ObservableCell";

@interface ObservablesViewController : UICollectionViewController <NSFetchedResultsControllerDelegate>

@property(strong, nonatomic) ObservationsViewController *observationsViewController;
@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (NSString *)name;
@end
