//
//  EEYEODetailViewController.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EEYEODetailViewController : UIViewController <UISplitViewControllerDelegate>

@property(strong, nonatomic) id detailItem;

@property(weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end