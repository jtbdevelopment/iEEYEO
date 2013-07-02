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
#import "Colors.h"
#import "CategoryPickerViewController.h"
#import "EEYEOLocalDataStore.h"

@interface ObservationViewController ()

@end

@implementation ObservationViewController {
@private
    NSDateFormatter *_dateFormatter;
    UITextView *_commentField;
    UIButton *_observableField;
    UIButton *_categoriesField;
    UIButton *_timestampField;
    UISwitch *_significantField;

    EEYEOObservation *_observation;
    EEYEOObservable *_observable;
    NSDate *_observationTimestamp;
    NSString *_comments;
    BOOL _significant;
    NSMutableSet *_categories;
}

@synthesize commentField = _commentField;
@synthesize observableField = _observableField;
@synthesize categoriesField = _categoriesField;
@synthesize timestampField = _timestampField;
@synthesize significantField = _significantField;

@synthesize observation = _observation;

//  TODO - remove cancel?

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
    [self view].backgroundColor = [Colors cream];
    [self commentField].backgroundColor = [UIColor whiteColor];
    [[self observableField] setBackgroundColor:[Colors darkBrown]];
    [self significantField].thumbTintColor = [Colors darkBrown];
    [self significantField].onTintColor = [Colors darkBrown];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _commentField.text = _comments;
    _significantField.on = _significant;
    [_timestampField setTitle:[_dateFormatter stringFromDate:_observationTimestamp] forState:UIControlStateNormal];
    [_categoriesField setTitle:[[_categories allObjects] componentsJoinedByString:@", "] forState:UIControlStateNormal];
    [_observableField setTitle:[_observable desc] forState:UIControlStateNormal];
}

- (void)setObservation:(EEYEOObservation *)observation {
    _observation = observation;
    _observable = observation.observable;
    _categories = [[NSMutableSet alloc] init];
    for (EEYEOObservationCategory *category in observation.categories) {
        [_categories addObject:category.shortName];
    }
    _significant = observation.significant;
    _observationTimestamp = observation.observationTSAsNSDate;
    _comments = observation.comment;
}

- (IBAction)editSignificant:(id)sender {
    _significant = _significantField.on;
}

- (IBAction)editObservable:(id)sender {

}

- (IBAction)editCategories:(id)sender {
    CategoryPickerViewController *categoryPickerViewController = [[CategoryPickerViewController alloc] initWithStyle:UITableViewStyleGrouped];
    categoryPickerViewController.managedObjectContext = [[EEYEOLocalDataStore instance] context];
    categoryPickerViewController.selectedCategories = _categories;
    [self.navigationController pushViewController:categoryPickerViewController animated:YES];
}

- (IBAction)editTimestamp:(id)sender {

}

- (IBAction)cancel:(id)sender {

}

- (IBAction)reset:(id)sender {

}

- (IBAction)save:(id)sender {

}


@end
