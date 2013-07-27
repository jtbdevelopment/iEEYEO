//
//  SettingsViewController.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property(nonatomic, retain) IBOutlet UILabel *status;
@property(nonatomic, retain) IBOutlet UILabel *refreshFrequency;
@property(nonatomic, retain) IBOutlet UILabel *localDirty;
@property(nonatomic, retain) IBOutlet UILabel *lastServerTS;
@property(nonatomic, retain) IBOutlet UITextField *login;
@property(nonatomic, retain) IBOutlet UITextField *password;
@property(nonatomic, retain) IBOutlet UITextField *website;
@property(nonatomic, retain) IBOutlet UIStepper *refreshStepper;

- (IBAction)refreshChange:(id)sender;

- (IBAction)testConnection:(id)sender;

- (IBAction)resync:(id)sender;

- (IBAction)reset:(id)sender;

- (IBAction)done:(id)sender;
@end
