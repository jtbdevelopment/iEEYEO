//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "EEYEOLocalDataStore.h"
#import "EEYEOAppUser.h"
#import "EEYEOClassList.h"
#import "EEYEOObservationCategory.h"
#import "EEYEOStudent.h"
#import "EEYEOObservation.h"


@implementation EEYEOLocalDataStore {

}

@synthesize model, context;

- (id)init {
    self = [super init];
    if (self) {

    }

    return self;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self instance];
}

+ (EEYEOLocalDataStore *)instance {
    static EEYEOLocalDataStore *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[super allocWithZone:nil] init];
        }
    }

    return _instance;
}

- (NSString *)daoDir {
    NSArray *docDirs = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *docDir = [docDirs objectAtIndex:0];
    NSString *dir = [docDir stringByAppendingPathComponent:@"eeyeo.data"];
    NSLog(@"Local dao to %@", dir);
    return dir;
}

- (id)find:(NSString *)entityType withId:(NSString *)withId {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityType inManagedObjectContext:context];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", withId];
    [request setPredicate:predicate];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    [controller setDelegate:self];

    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (error != nil || result == nil || [result count] == 0) {
        return nil;
    }
    if ([result count] > 1) {
        //  TODO
    }
    return [result objectAtIndex:0];
}

- (id)create:(NSString *)entityType {
    return [NSEntityDescription insertNewObjectForEntityForName:entityType inManagedObjectContext:context];
}

//  TODO - get rid  of me - helper for dummy data for now
- (id)findOrCreate:(NSString *)entityType withId:(NSString *)withId {
    id entity = [self find:entityType withId:withId];
    if (!entity) {
        entity = [self create:entityType];
        [(EEYEOIdObject *) entity setId:withId];
    }
    return entity;
}

//  TODO - get rid of me
- (void)createDummyData {
    NSError *error = nil;

    EEYEOAppUser *appUser = [self findOrCreate:APPUSERENTITY withId:@"U1"];
    [appUser setActivated:YES];
    [appUser setActive:YES];
    [appUser setEmailAddress:@"test@test.com"];
    [appUser setFirstName:@"first"];
    [appUser setLastName:@"last"];
    [context save:&error];

    EEYEOClassList *classList = [self findOrCreate:CLASSLISTENTITY withId:@"CL1"];
    [classList setDesc:@"A Class"];
    [classList setAppUser:appUser];
    [classList setModificationTimestamp:1];
    [context save:&error];

    EEYEOObservationCategory *observationCategory1 = [self findOrCreate:CATEGORYENTITY withId:@"OC1"];
//    [observationCategory1 setModificationTimestamp:(int64_t)2];
    [observationCategory1 setShortName:@"OC1"];
    [observationCategory1 setDesc:@"Observation Category 1"];
    [observationCategory1 setAppUser:appUser];
    [context save:&error];

    EEYEOObservationCategory *observationCategory2 = [self findOrCreate:CATEGORYENTITY withId:@"OC2"];
//    [observationCategory2 setModifdicationTimestamp:2];
    [observationCategory2 setShortName:@"OC2"];
    [observationCategory2 setDesc:@"Observation Category 2"];
    [observationCategory2 setAppUser:appUser];
    [context save:&error];

    EEYEOStudent *student = [self findOrCreate:STUDENTENTITY withId:@"S1"];
    [student setFirstName:@"first"];
    [student setLastName:@"Last"];
    [student addClassListsObject:classList];
    [student setAppUser:appUser];
    [student setModificationTimestamp:5];
    [context save:&error];

    EEYEOObservation *observation = [self findOrCreate:OBSERVATIONENTITY withId:@"O1"];
    [observation setModificationTimestamp:6];
    [observation setObservationTimestamp:6];
    [observation addCategoriesObject:observationCategory1];
    [observation addCategoriesObject:observationCategory2];
    [observation setComment:@"An observation"];
    [observation setObservable:student];
    [observation setSignificant:YES];
    [observation setAppUser:appUser];
    [context save:&error];
}


@end