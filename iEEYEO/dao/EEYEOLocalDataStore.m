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
    NSDate *date = nil;

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
    date = [NSDate dateWithTimeIntervalSinceNow:0];
    [classList setModificationTSAsNSDate:date];
    [context save:&error];

    EEYEOObservationCategory *observationCategory1 = [self findOrCreate:CATEGORYENTITY withId:@"OC1"];
    [observationCategory1 setShortName:@"OC1"];
    [observationCategory1 setDesc:@"Observation Category 1"];
    [observationCategory1 setAppUser:appUser];
    date = [NSDate dateWithTimeIntervalSinceNow:0];
    [observationCategory1 setModificationTSAsNSDate:date];
    [context save:&error];

    EEYEOObservationCategory *observationCategory2 = [self findOrCreate:CATEGORYENTITY withId:@"OC2"];
    [observationCategory2 setShortName:@"OC2"];
    [observationCategory2 setDesc:@"Observation Category 2"];
    [observationCategory2 setAppUser:appUser];
    date = [NSDate dateWithTimeIntervalSinceNow:0];
    [observationCategory1 setModificationTSAsNSDate:date];
    [context save:&error];

    EEYEOStudent *student1 = [self findOrCreate:STUDENTENTITY withId:@"S1"];
    [student1 setFirstName:@"student"];
    [student1 setLastName:@"1"];
    [student1 addClassListsObject:classList];
    [student1 setAppUser:appUser];
    [student1 setModificationTimestamp:5];
    [context save:&error];

    EEYEOStudent *student2 = [self findOrCreate:STUDENTENTITY withId:@"S2"];
    [student2 setFirstName:@"student"];
    [student2 setLastName:@"2"];
    [student2 addClassListsObject:classList];
    [student2 setAppUser:appUser];
    [student2 setModificationTimestamp:5];
    [context save:&error];

    for (int i = 2; i < 51; ++i) {
        NSMutableString *id = [[NSMutableString alloc] initWithString:@"S"];
        [id appendFormat:@"%d", i];
        EEYEOStudent *student2 = [self findOrCreate:STUDENTENTITY withId:id];
        [student2 setFirstName:@"student"];
        [student2 setLastName:id];
        [student2 addClassListsObject:classList];
        [student2 setAppUser:appUser];
        [student2 setModificationTimestamp:5];
        [context save:&error];
    }

    for (int i = 1; i < 15; ++i) {
        NSMutableString *id = [[NSMutableString alloc] initWithString:@"O"];
        [id appendFormat:@"%d", i];

        EEYEOObservation *observation = [self findOrCreate:OBSERVATIONENTITY withId:id];
        [observation setModificationTSAsNSDate:[NSDate dateWithTimeIntervalSinceNow:0]];
        date = [NSDate dateWithTimeIntervalSinceNow:(i * 60 * 60 * 24 * -1)];
        [observation setObservationTSAsNSDate:date];
        [observation addCategoriesObject:observationCategory1];
        [observation addCategoriesObject:observationCategory2];
        [observation setComment:@"An observation"];
        if (i % 3 == 0) {
            [observation setObservable:student1];
        } else if (i % 3 == 1) {
            [observation setObservable:student2];
        } else {
            [observation setObservable:classList];
        }
        [observation setSignificant:YES];
        [observation setAppUser:appUser];
        [context save:&error];
    }
}


@end