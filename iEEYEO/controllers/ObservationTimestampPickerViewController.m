//
//  ObservationTimestampPickerViewController.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "ObservationTimestampPickerViewController.h"

@interface ObservationTimestampPickerViewController ()

@end

@implementation ObservationTimestampPickerViewController {
@private
    UIDatePicker *_pickerField;
    NSMutableArray *_timestamp;
}

@synthesize pickerField = _pickerField;

@synthesize timestamp = _timestamp;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_pickerField setDate:[_timestamp objectAtIndex:0] animated:YES];
}

- (IBAction)pickerChanged:(id)sender {
    [_timestamp setObject:[_pickerField date] atIndexedSubscript:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
