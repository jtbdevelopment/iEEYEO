//
//  ObservationTimestampPickerViewController.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ObservationTimestampPickerViewController : UIViewController

@property(nonatomic, retain) NSMutableArray *timestamp;  // TODO - array of 1, do better
@property(nonatomic, retain) IBOutlet UIDatePicker *pickerField;

- (IBAction)pickerChanged:(id)sender;

@end
