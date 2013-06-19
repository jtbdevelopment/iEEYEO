//
//  EEYEODetailViewController.h
//  iEEYEO
//
//  Created by Joseph Buscemi on 06/18/13.
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EEYEODetailViewController : UIViewController <UISplitViewControllerDelegate>

@property(strong, nonatomic) id detailItem;

@property(weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end