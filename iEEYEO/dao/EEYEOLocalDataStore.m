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
    [classList setModificationTimestampFromNSDate:date];
    [context save:&error];

    NSMutableArray *categories = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 5; ++i) {
        NSMutableString *id = [[NSMutableString alloc] initWithString:@"OC"];
        [id appendFormat:@"%d", i];

        EEYEOObservationCategory *observationCategory = [self findOrCreate:CATEGORYENTITY withId:id];
        [observationCategory setShortName:id];
        [observationCategory setDesc:@"Observation Category"];
        [observationCategory setAppUser:appUser];
        date = [NSDate dateWithTimeIntervalSinceNow:0];
        [observationCategory setModificationTimestampFromNSDate:date];
        [context save:&error];
        [categories addObject:observationCategory];
    }

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

    for (unsigned i = 1; i < 15; ++i) {
        NSMutableString *id = [[NSMutableString alloc] initWithString:@"O"];
        [id appendFormat:@"%d", i];

        EEYEOObservation *observation = [self findOrCreate:OBSERVATIONENTITY withId:id];
        [observation setModificationTimestampFromNSDate:[NSDate dateWithTimeIntervalSinceNow:0]];
        double secs = (double) i * (double) 24.0 * 60.0 * 60.0;
        secs = secs * -1;
        date = [NSDate dateWithTimeIntervalSinceNow:secs];
        [observation setObservationTimestampFromNSDate:date];
        NSSet *oldC = [[NSSet alloc] initWithSet:observation.categories];
        for (EEYEOObservationCategory *category in oldC) {
            [observation removeCategoriesObject:category];
        }
        [observation addCategoriesObject:[categories objectAtIndex:(i % 3)]];
        [observation addCategoriesObject:[categories objectAtIndex:(i % 5)]];
        NSString *comment = [NSString stringWithFormat:@"An observation %d", i];
        [observation setComment:comment];
        if (i % 3 == 0) {
            [observation setObservable:student1];
        } else if (i % 3 == 1) {
            [observation setObservable:student2];
        } else {
            [observation setObservable:classList];
        }
        if (i % 2 == 0) {
            [observation setSignificant:YES];
        } else {
            [observation setSignificant:NO];
        }
        [observation setAppUser:appUser];
        [context save:&error];
    }
}


@end