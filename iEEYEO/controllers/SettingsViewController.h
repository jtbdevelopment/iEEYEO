//
//  SettingsViewController.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const CHANGE_CONNECTION = @"Change Connection Details";

static NSString *const TEST_CONNECTION_ONLY = @"Press Test To Complete";

static NSString *const CANCEL_OR_TEST_CONNECTION = @"Press to Cancel Changes or Press Test To Complete Changes";

@interface SettingsViewController : UIViewController <UIAlertViewDelegate>

@property(nonatomic, retain) IBOutlet UILabel *refreshFrequency;
@property(nonatomic, retain) IBOutlet UILabel *local;
@property(nonatomic, retain) IBOutlet UILabel *localDirty;
@property(nonatomic, retain) IBOutlet UILabel *lastServerTS;
@property(nonatomic, retain) IBOutlet UILabel *lastResyncTS;
@property(nonatomic, retain) IBOutlet UITextField *login;
@property(nonatomic, retain) IBOutlet UITextField *password;
@property(nonatomic, retain) IBOutlet UITextField *website;
@property(nonatomic, retain) IBOutlet UIStepper *refreshStepper;

@property(nonatomic, retain) IBOutlet UIButton *editConnections;
@property(nonatomic, retain) IBOutlet UIButton *resyncButton;
@property(nonatomic, retain) IBOutlet UIButton *resetButton;

+ (BOOL)forceConnectionSettings;

- (IBAction)enableEditing:(id)sender;

- (IBAction)refreshChange:(id)sender;

- (IBAction)testConnection:(id)sender;

- (IBAction)resync:(id)sender;

- (IBAction)reset:(id)sender;

@end
