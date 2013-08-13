//
//  ObservationViewController.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EEYEOObservation;

static NSString *const THUMBNAIL_CELL = @"ThumbnailCell";

@interface ObservationViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate>
@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, retain) IBOutlet UITextView *commentField;
@property(nonatomic, retain) IBOutlet UIButton *observableField;
@property(nonatomic, retain) IBOutlet UIButton *categoriesField;
@property(nonatomic, retain) IBOutlet UIButton *timestampField;
@property(nonatomic, retain) IBOutlet UISwitch *significantField;
@property(nonatomic, retain) IBOutlet UICollectionView *images;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *cameraButton;

@property(nonatomic, strong) EEYEOObservation *observation;

- (void)setObservation:(EEYEOObservation *)observation AndIsNew:(BOOL)isNew;

- (IBAction)editObservable:(id)sender;

- (IBAction)editCategories:(id)sender;

- (IBAction)editTimestamp:(id)sender;

- (IBAction)reset:(id)sender;

- (void)done:(id)sender;

- (IBAction)trash:(id)sender;

- (IBAction)camera:(id)sender;

- (IBAction)photos:(id)sender;

@end
