//
//  SettingsViewController.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "SettingsViewController.h"
#import "EEYEOLocalDataStore.h"
#import "EEYEORemoteDataStore.h"
#import "BaseRESTDelegate.h"

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

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadValues];

}

- (void)loadValues {
//  TODO - real defaults/recovery
    [_refreshStepper setValue:1.0];
    [self refreshChange:nil];

    [_localDirty setText:[NSString stringWithFormat:@"%d", [[[EEYEOLocalDataStore instance] getDirtyEntities:APPUSEROWNEDENTITY] count]]];
    [_lastServerTS setText:[[EEYEORemoteDataStore instance] getLastUpdateFromServerAsString]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshChange:(id)sender {
    [_refreshFrequency setText:[NSString stringWithFormat:@"%d Hours`", (int) _refreshStepper.value]];
}

- (IBAction)testConnection:(id)sender {
    //  TODO - base
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Authentication" message:@"Worked!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    if ([BaseRESTDelegate authenticateConnection:[_login text] password:[_password text] AndBaseURL:BASE_REST_URL]) {
        [alertView setMessage:@"Connected Successfully"];
    } else {
        [alertView setMessage:@"Failed.  Please try again."];
    }
    [alertView show];
}

- (IBAction)resync:(id)sender {
    [[EEYEORemoteDataStore instance] resyncWithRemoteServer];
    [self loadValues];
}

- (IBAction)reset:(id)sender {

}

- (IBAction)done:(id)sender {

}

@end
