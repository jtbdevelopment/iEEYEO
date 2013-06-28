//
//  ObservationViewController.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EEYEOObservation;

@interface ObservationViewController : UIViewController
@property(nonatomic, retain) IBOutlet UITextView *comments;
@property(nonatomic, retain) IBOutlet UIButton *observable;
@property(nonatomic, retain) IBOutlet UIButton *categories;
@property(nonatomic, retain) IBOutlet UIButton *timestamp;
@property(nonatomic, retain) IBOutlet UISwitch *significant;

@property(nonatomic, strong) EEYEOObservation *observation;

- (void)setObservation:(EEYEOObservation *)observation;
@end
