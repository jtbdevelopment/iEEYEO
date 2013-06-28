//
//  ObservationViewController.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "ObservationViewController.h"
#import "EEYEOObservation.h"
#import "EEYEOObservable.h"
#import "EEYEOObservationCategory.h"

@interface ObservationViewController ()

@end

@implementation ObservationViewController {
@private
    NSDateFormatter *_dateFormatter;
    UITextView *_comments;
    UIButton *_observable;
    UIButton *_categories;
    UIButton *_timestamp;
    UISwitch *_significant;
    EEYEOObservation *_observation;
}

@synthesize comments = _comments;
@synthesize observable = _observable;
@synthesize categories = _categories;
@synthesize timestamp = _timestamp;
@synthesize significant = _significant;

@synthesize observation = _observation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //  TODO - central
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setObservation:(EEYEOObservation *)observation {
    _comments.text = observation.comment;
    _significant.on = observation.significant;
    [_timestamp setTitle:[_dateFormatter stringFromDate:[observation observationTSAsNSDate]] forState:UIControlStateNormal];
    NSMutableArray *codes = [[NSMutableArray alloc] init];
    for (EEYEOObservationCategory *category in [observation categories]) {
        [codes addObject:category.shortName];
    }
    [_categories setTitle:[codes componentsJoinedByString:@", "] forState:UIControlStateNormal];
    [_observable setTitle:[[observation observable] desc] forState:UIControlStateNormal];
    _observation = observation;
}


@end
