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
#import "InitialAuthenticationDelegate.h"
#import "Colors.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController {
@private
    UILabel *_refreshFrequency;
    UILabel *_localDirty;
    UILabel *_lastServerTS;
    UITextField *_login;
    UITextField *_password;
    UITextField *_website;
    UIStepper *_refreshStepper;
    UILabel *_local;

    NSTimer *_timer;
}

@synthesize refreshFrequency = _refreshFrequency;
@synthesize localDirty = _localDirty;
@synthesize lastServerTS = _lastServerTS;
@synthesize login = _login;
@synthesize password = _password;
@synthesize website = _website;
@synthesize refreshStepper = _refreshStepper;
@synthesize local = _local;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if ([self tabBarItem]) {
            [[self tabBarItem] setTitle:@"Settings"];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_refreshStepper setMaximumValue:24.0];
    [_refreshStepper setMinimumValue:1.0];
    [_refreshStepper setStepValue:1.0];
    [_editConnections setTitle:CHANGE_CONNECTION forState:UIControlStateNormal];
    [[self view] setBackgroundColor:[Colors cream]];
    [self setTitle:@"Settings"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_refreshStepper setValue:[[EEYEORemoteDataStore instance] refreshFrequency]];
    [self refreshChange:nil];

#if TARGET_IPHONE_SIMULATOR
    static NSString *const DEFAULT_REST_URL = @"http://Josephs-MacBook-Pro.local:8080/REST/";
#else
    static NSString *const DEFAULT_REST_URL = @"http://www.e-eye-o.com/REST/";
#endif
    EEYEOLocalDataStore *localDataStore = [EEYEOLocalDataStore instance];
    NSString *url = [localDataStore website];
    if ([url isEqualToString:@""]) {
        url = DEFAULT_REST_URL;
    }
    [_website setText:url];
    [_login setText:[localDataStore login]];
    [_password setText:[localDataStore password]];

    if ([SettingsViewController forceConnectionSettings]) {
        [self enableEditing:nil];
    } else {
        [self disableEditing];
    }
    [self loadLocalStoreValues];
    if (_timer) {
        [_timer invalidate];
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(refreshTimer:) userInfo:nil repeats:YES];
}

+ (BOOL)forceConnectionSettings {
    EEYEOLocalDataStore *localDataStore = [EEYEOLocalDataStore instance];
    return [[localDataStore login] length] == 0 || [[localDataStore password] length] == 0 || [[localDataStore website] length] == 0 || [localDataStore findAppUserWithEmailAddress:[localDataStore login]] == nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [_timer invalidate];
    [super viewWillDisappear:animated];
}

- (void)loadLocalStoreValues {
    [_local setText:[NSString stringWithFormat:@"%d", [[[EEYEOLocalDataStore instance] getEntitiesOfType:APPUSEROWNEDENTITY WithPredicate:nil] count]]];
    [_localDirty setText:[NSString stringWithFormat:@"%d", [[[EEYEOLocalDataStore instance] getDirtyEntities:APPUSEROWNEDENTITY] count]]];
    [_lastServerTS setText:[[EEYEORemoteDataStore instance] lastUpdateFromServerAsString]];
    [_lastResyncTS setText:[[EEYEORemoteDataStore instance] lastServerResyncAsString]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)disableEditing {
    [_editConnections setEnabled:YES];
    [_editConnections setTitle:CHANGE_CONNECTION forState:UIControlStateNormal];
    [_resetButton setEnabled:YES];
    [_resyncButton setEnabled:YES];
    [_refreshStepper setEnabled:YES];
    [_login setEnabled:NO];
    [_password setEnabled:NO];
    [_website setEnabled:NO];
    [[EEYEORemoteDataStore instance] startRemoteSyncs];
    [[self navigationController] setNavigationBarHidden:NO];
}

- (IBAction)enableEditing:(id)sender {
    static NSString *uneditedLogin, *uneditedPassword, *uneditedWebSite;

    if (sender == nil || [[[_editConnections titleLabel] text] isEqual:CHANGE_CONNECTION]) {
        uneditedLogin = [_login text];
        uneditedPassword = [_password text];
        uneditedWebSite = [_website text];
        [self activateEditing:sender];
    } else {
        [_login setText:uneditedLogin];
        [_website setText:uneditedWebSite];
        [_password setText:uneditedPassword];
        if ([SettingsViewController forceConnectionSettings]) {
            [self enableEditing:nil];
        } else {
            [self disableEditing];
        }
    }
}

- (void)activateEditing:(id)sender {
    [[EEYEORemoteDataStore instance] haltRemoteSyncs];
    [_login setEnabled:YES];
    [_password setEnabled:YES];
    [_website setEnabled:YES];
    if (sender) {
        [_editConnections setEnabled:YES];
        [_editConnections setTitle:CANCEL_OR_TEST_CONNECTION forState:UIControlStateNormal];
    } else {
        [_editConnections setEnabled:NO];
        [_editConnections setTitle:TEST_CONNECTION_ONLY forState:UIControlStateNormal];
    }
    [_resetButton setEnabled:NO];
    [_resyncButton setEnabled:NO];
    [_refreshStepper setEnabled:NO];
    [[self navigationController] setNavigationBarHidden:YES];
}

- (IBAction)refreshChange:(id)sender {
    [_refreshFrequency setText:[NSString stringWithFormat:@"%d Hours`", (int) _refreshStepper.value]];
    [[EEYEORemoteDataStore instance] setRefreshFrequency:(int) _refreshStepper.value];
}

//  TODO - alerts show up after the fact not before
- (IBAction)testConnection:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Authentication" message:@"Worked!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    InitialAuthenticationDelegate *delegate = [[InitialAuthenticationDelegate alloc] init];
    EEYEOLocalDataStore *localDataStore = [EEYEOLocalDataStore instance];
    NSString *originalLogin = [localDataStore login];
    NSString *originalWebsite = [localDataStore website];
    if ([delegate authenticateConnection:[_login text] password:[_password text] AndBaseURL:[_website text]]) {
        [alertView setMessage:@"Connected Successfully.  Resycning data..."];
        [alertView show];
        if ([[_login text] isEqualToString:originalLogin] && [[_website text] isEqualToString:originalWebsite] && ![[[_editConnections titleLabel] text] isEqualToString:TEST_CONNECTION_ONLY]) {
            [[EEYEORemoteDataStore instance] resyncWithRemoteServer];
        } else {
            [alertView setMessage:@"Connected Successfully.  New or changed user or website.  Resetting data..."];
            [localDataStore clearAllItems];
            [[EEYEORemoteDataStore instance] initializeFromRemoteServer];
        }
        [self disableEditing];
    } else {
        [alertView setMessage:@"Failed.  Please try again."];
        [alertView show];
    }
}

- (void)refreshTimer:(NSTimer *)timer {
    [self loadLocalStoreValues];
}

- (IBAction)resync:(id)sender {
    [[EEYEORemoteDataStore instance] resyncWithRemoteServer];
    [self loadLocalStoreValues];
}

- (IBAction)reset:(id)sender {
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Reset all data and load from server"
                                                   message:@"This will lose any unsynced changes.  Are you sure?"
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Reset", nil];
    [view show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[EEYEOLocalDataStore instance] clearAllItems];
        [[EEYEORemoteDataStore instance] initializeFromRemoteServer];
        [self loadLocalStoreValues];
    }
}


@end
