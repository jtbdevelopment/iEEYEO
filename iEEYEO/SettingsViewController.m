//
//  SettingsViewController.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController {
@private
    UILabel *_status;
    UILabel *_refreshFrequency;
    UILabel *_localDirty;
    UILabel *_lastServerTS;
    UITextField *_login;
    UITextField *_password;
    UITextField *_website;
    UIStepper *_refreshStepper;
}

@synthesize status = _status;
@synthesize refreshFrequency = _refreshFrequency;
@synthesize localDirty = _localDirty;
@synthesize lastServerTS = _lastServerTS;
@synthesize login = _login;
@synthesize password = _password;
@synthesize website = _website;
@synthesize refreshStepper = _refreshStepper;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_refreshStepper setMaximumValue:24.0];
    [_refreshStepper setMinimumValue:1.0];
    [_refreshStepper setStepValue:1.0];

    //  TODO - real defaults/recovery
    [_refreshFrequency setText:@"2"];
    [_refreshStepper setValue:2.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshChange:(id)sender {
    [_refreshFrequency setText:[NSString stringWithFormat:@"%d Hours", (int) _refreshStepper.value]];
}

- (IBAction)testConnection:(id)sender {

}

- (IBAction)resync:(id)sender {

}

- (IBAction)reset:(id)sender {

}

- (IBAction)done:(id)sender {

}

@end
