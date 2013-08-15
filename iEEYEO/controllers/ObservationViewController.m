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
#import "EEYEOPhoto.h"
#import "PhotoThumbnailCell.h"
#import "PhotoThumbnailViewLayout.h"
#import "NSDateWithMillis.h"

//  TODO - make this all look a heck of lot nicer
//  TODO - look into custom inputs for setting fields instead of more screens

@interface ObservationViewController ()
@end

//  TODO - nasty
typedef NS_ENUM(NSInteger, ChildPopping) {
    None,
    Observable,
    Categories,
    Timestamp
};

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
    NSMutableSet *_categories;
    NSMutableArray *_photos;
    NSMutableArray *_newPhotos;
    NSMutableArray *_deletedPhotos;
    NSManagedObjectContext *_managedObjectContext;
    BOOL _newObservation;
    ChildPopping _childPopping;
    UICollectionView *_images;
    UIBarButtonItem *_cameraButton;

    UIImagePickerController *_imagePicker;
    UIPopoverController *_imagePopover;
}

@synthesize commentField = _commentField;
@synthesize observableField = _observableField;
@synthesize categoriesField = _categoriesField;
@synthesize timestampField = _timestampField;
@synthesize significantField = _significantField;

@synthesize observation = _observation;

@synthesize managedObjectContext = _managedObjectContext;

@synthesize images = _images;

@synthesize cameraButton = _cameraButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //  TODO - central
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        _observable = [[NSMutableArray alloc] init];
        _observationTimestamp = [[NSMutableArray alloc] init];
        _photos = [[NSMutableArray alloc] init];
        _newPhotos = [[NSMutableArray alloc] init];
        _deletedPhotos = [[NSMutableArray alloc] init];
        _childPopping = None;
        _imagePicker = [[UIImagePickerController alloc] init];
        [_imagePicker setDelegate:self];
    }
    return self;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [[collectionView cellForItemAtIndexPath:indexPath] setHighlighted:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [[collectionView cellForItemAtIndexPath:indexPath] setHighlighted:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self view].backgroundColor = [Colors cream];
    [self commentField].backgroundColor = [UIColor whiteColor];
    [self significantField].thumbTintColor = [Colors darkBrown];
    [self significantField].onTintColor = [Colors darkBrown];
    [[self images] setDataSource:self];
    UINib *nib = [UINib nibWithNibName:@"PhotoThumbnailCell" bundle:nil];
    [[self images] registerNib:nib forCellWithReuseIdentifier:THUMBNAIL_CELL];
    [[self images] setCollectionViewLayout:[[PhotoThumbnailViewLayout alloc] init]];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(reset:)];
    doneButton.title = @"Done";
    resetButton.title = @"Reset";
    [[self navigationItem] setRightBarButtonItems:[NSArray arrayWithObjects:doneButton, resetButton, nil] animated:YES];
    [self.images setOpaque:NO];
    [self.images setAllowsSelection:YES];
    [self.images setBackgroundColor:[Colors cream]];
    [self.images setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [_cameraButton setEnabled:YES];
    } else {
        [_cameraButton setEnabled:NO];
    }

    switch (_childPopping) {
        case None:
            [self updateCommentField];
            [self updateSignificantField];
            [self updateTimestampField];
            [self updateCategoriesField];
            [self updateObservableField];
            break;
        case Observable:
            [self updateObservableField];
            break;
        case Categories:
            [self updateCategoriesField];
            break;
        case Timestamp:
            [self updateTimestampField];
            break;
    }
    _childPopping = None;
}

- (void)updateObservableField {
    [_observableField setTitle:[[_observable objectAtIndex:0] desc] forState:UIControlStateNormal];
}

- (IBAction)trash:(id)sender {
    while ([[[self images] indexPathsForSelectedItems] count] > 0) {
        NSIndexPath *ip = [[[self images] indexPathsForSelectedItems] objectAtIndex:0];
        int i = [ip indexAtPosition:1];
        [_deletedPhotos addObject:[_photos objectAtIndex:i]];
        [_photos removeObjectAtIndex:i];
        [[self images] reloadData];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    _imagePopover = nil;
}

- (IBAction)camera:(id)sender {
    [_imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self popoverPhotos:sender];
}

- (IBAction)photos:(id)sender {
    [_imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    [self popoverPhotos:sender];
}

- (void)popoverPhotos:(id)sender {
    if (!_imagePopover) {
        _imagePopover = [[UIPopoverController alloc] initWithContentViewController:_imagePicker];
        [_imagePopover setDelegate:self];
        [_imagePopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)updateCategoriesField {
    NSMutableString *categories = [[NSMutableString alloc] init];
    BOOL first = YES;
    for (EEYEOObservationCategory *category in _categories) {
        if (first) {
            first = NO;

        } else {
            [categories appendString:@", "];
        }
        [categories appendFormat:@"%@", [category shortName]];
    }
    [_categoriesField setTitle:categories forState:UIControlStateNormal];
}

- (void)updateTimestampField {
    [_timestampField setTitle:[_dateFormatter stringFromDate:[_observationTimestamp objectAtIndex:0]] forState:UIControlStateNormal];
}

- (void)updateSignificantField {
    _significantField.on = [_observation significant];
}

- (void)updateCommentField {
    _commentField.text = [_observation comment];
}

- (void)setObservation:(EEYEOObservation *)observation AndIsNew:(BOOL)isNew {
    _observation = observation;
    [_observable setObject:observation.observable atIndexedSubscript:0];
    _categories = [[NSMutableSet alloc] init];
    [_categories addObjectsFromArray:[[_observation categories] allObjects]];
    [_observationTimestamp setObject:[observation observationTimestampToNSDate] atIndexedSubscript:0];
    [_photos removeAllObjects];
    [_photos addObjectsFromArray:[[observation photos] allObjects]];
    [[self navigationItem] setTitle:[_observation desc]];
    [_images reloadData];
    _newObservation = isNew;
}

- (void)reset:(id)sender {
    [self setObservation:_observation];
    [self viewWillAppear:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_childPopping == None) {
        //  Anything still in here was added but we are not saving the change
        for (EEYEOPhoto *created in _newPhotos) {
            [[EEYEOLocalDataStore instance] deleteFromLocalStore:created];
        }
        if (_observation && _newObservation) {
            [[EEYEOLocalDataStore instance] deleteFromLocalStore:_observation];
        }
    }
}

- (void)done:(id)sender {
    for (EEYEOPhoto *deleted in _deletedPhotos) {
        [[EEYEOLocalDataStore instance] deleteFromLocalStore:deleted];
    }
    [_observation setSignificant:[_significantField isOn]];
    [_observation setComment:[_commentField text]];
    [_observation setObservationTimestampFromNSDate:[_observationTimestamp objectAtIndex:0]];
    [_observation setCategories:_categories];
    [_observation setObservable:[_observable objectAtIndex:0]];
    NSSet *set = [NSSet setWithArray:_photos];
    [_observation setPhotos:set];

    for (EEYEOPhoto *created in _newPhotos) {
        [created setPhotoFor:_observation];
        [[EEYEOLocalDataStore instance] saveToLocalStore:created];
    }
    [[EEYEOLocalDataStore instance] saveToLocalStore:_observation];
    [_newPhotos removeAllObjects];
    [_deletedPhotos removeAllObjects];
    [[EEYEOLocalDataStore instance] saveToLocalStore:_observation];
    _newObservation = NO;
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)editObservable:(id)sender {
    ObservablePickerViewController *controller = [[ObservablePickerViewController alloc] init];
    controller.managedObjectContext = [[EEYEOLocalDataStore instance] context];
    controller.observable = _observable;
    _childPopping = Observable;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)editCategories:(id)sender {
    CategoryPickerViewController *categoryPickerViewController = [[CategoryPickerViewController alloc] initWithStyle:UITableViewStyleGrouped];
    categoryPickerViewController.managedObjectContext = [[EEYEOLocalDataStore instance] context];
    categoryPickerViewController.selectedCategories = _categories;
    _childPopping = Categories;
    [self.navigationController pushViewController:categoryPickerViewController animated:YES];
}

- (IBAction)editTimestamp:(id)sender {
    ObservationTimestampPickerViewController *picker = [[ObservationTimestampPickerViewController alloc] init];
    [picker setTimestamp:_observationTimestamp];
    _childPopping = Timestamp;
    [self.navigationController pushViewController:picker animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_photos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoThumbnailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:THUMBNAIL_CELL forIndexPath:indexPath];

    id photo = [_photos objectAtIndex:[indexPath indexAtPosition:1]];
    [[cell label] setText:[photo name]];
    [[cell imageView] setImage:[photo thumbnailImage]];
    return cell;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    EEYEOPhoto *photo = [[EEYEOLocalDataStore instance] create:PHOTOENTITY];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [photo setImageFromImage:image];
    [photo setName:[NSString stringWithFormat:@"Photo %d", [[[NSDateWithMillis dateWithTimeIntervalFromNow:0] toJodaDateTime] intValue]]];
    [photo setTimestampFromNSDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    [photo setAppUser:[[EEYEOLocalDataStore instance] appUser]];
    [_newPhotos addObject:photo];
    [_photos addObject:photo];
    [_images reloadData];
    [_imagePopover dismissPopoverAnimated:YES];
    _imagePopover = nil;
}


@end
