//
//  ObservationViewController.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EEYEOObservation;

@interface ObservationViewController : UIViewController
@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, retain) IBOutlet UITextView *commentField;
@property(nonatomic, retain) IBOutlet UIButton *observableField;
@property(nonatomic, retain) IBOutlet UIButton *categoriesField;
@property(nonatomic, retain) IBOutlet UIButton *timestampField;
@property(nonatomic, retain) IBOutlet UISwitch *significantField;

@property(nonatomic, strong) EEYEOObservation *observation;

- (void)setObservation:(EEYEOObservation *)observation;

- (IBAction)editSignificant:(id)sender;

- (IBAction)editObservable:(id)sender;

- (IBAction)editCategories:(id)sender;

- (IBAction)editTimestamp:(id)sender;

- (IBAction)cancel:(id)sender;

- (IBAction)reset:(id)sender;

- (IBAction)save:(id)sender;

@end
