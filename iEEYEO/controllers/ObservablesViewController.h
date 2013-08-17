//
//  ObservablesViewController.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ObservationsViewController;

static NSString *const OBSERVABLE_CELL = @"ObservableCell";

@interface ObservablesViewController : UIViewController <NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic, retain) IBOutlet UICollectionView *collectionView;
@property(strong, nonatomic) ObservationsViewController *observationsViewController;
@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (NSString *)name;
@end
