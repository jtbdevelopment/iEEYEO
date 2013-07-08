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
#import "ObservationTimestampPickerViewController.h"
#import "ObservablePickerViewController.h"

//  TODO - make this all look a heck of lot nicer
//  TODO - look into custom inputs for setting fields instead of more screens
//  TODO - photos

@interface ObservationViewController ()
- (void)reset:(id)sender;
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
    NSMutableArray *_observable;
    NSMutableArray *_observationTimestamp;
    NSString *_comments;
    BOOL _significant;
    NSMutableSet *_categories;
    NSManagedObjectContext *_managedObjectContext;
}

@synthesize commentField = _commentField;
@synthesize observableField = _observableField;
@synthesize categoriesField = _categoriesField;
@synthesize timestampField = _timestampField;
@synthesize significantField = _significantField;

@synthesize observation = _observation;

//  TODO - remove cancel?

@synthesize managedObjectContext = _managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //  TODO - central
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        _observable = [[NSMutableArray alloc] init];
        _observationTimestamp = [[NSMutableArray alloc] init];

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
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(reset:)];
    doneButton.title = @"Done";
    resetButton.title = @"Reset";
    [[self navigationItem] setRightBarButtonItems:[NSArray arrayWithObjects:doneButton, resetButton, nil] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _commentField.text = _comments;
    _significantField.on = _significant;
    [_timestampField setTitle:[_dateFormatter stringFromDate:[_observationTimestamp objectAtIndex:0]] forState:UIControlStateNormal];
    [_categoriesField setTitle:[[_categories allObjects] componentsJoinedByString:@", "] forState:UIControlStateNormal];
    [_observableField setTitle:[[_observable objectAtIndex:0] desc] forState:UIControlStateNormal];
}

- (void)setObservation:(EEYEOObservation *)observation {
    _observation = observation;
    [_observable setObject:observation.observable atIndexedSubscript:0];
    _categories = [[NSMutableSet alloc] init];
    for (EEYEOObservationCategory *category in observation.categories) {
        [_categories addObject:category.shortName];
    }
    _significant = observation.significant;
    [_observationTimestamp setObject:observation.observationTSAsNSDate atIndexedSubscript:0];
    _comments = observation.comment;
    [[self navigationItem] setTitle:[_observation desc]];
}

- (void)reset:(id)sender {
    [self setObservation:_observation];
    [self viewWillAppear:NO];
}

- (void)done:(id)sender {
    [_observation setSignificant:[_significantField isOn]];
    [_observation setComment:[_commentField text]];
    [_observation setObservationTSAsNSDate:[_observationTimestamp objectAtIndex:0]];
    NSError *error = [[NSError alloc] init];
    [_managedObjectContext save:&error];
    //  TODO - error
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)editSignificant:(id)sender {
    _significant = _significantField.on;
}

- (IBAction)editObservable:(id)sender {
    ObservablePickerViewController *controller = [[ObservablePickerViewController alloc] init];
    controller.managedObjectContext = [[EEYEOLocalDataStore instance] context];
    controller.observable = _observable;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)editCategories:(id)sender {
    CategoryPickerViewController *categoryPickerViewController = [[CategoryPickerViewController alloc] initWithStyle:UITableViewStyleGrouped];
    categoryPickerViewController.managedObjectContext = [[EEYEOLocalDataStore instance] context];
    categoryPickerViewController.selectedCategories = _categories;
    [self.navigationController pushViewController:categoryPickerViewController animated:YES];
}

- (IBAction)editTimestamp:(id)sender {
    ObservationTimestampPickerViewController *picker = [[ObservationTimestampPickerViewController alloc] init];
    [picker setTimestamp:_observationTimestamp];
    [self.navigationController pushViewController:picker animated:YES];
}


@end
