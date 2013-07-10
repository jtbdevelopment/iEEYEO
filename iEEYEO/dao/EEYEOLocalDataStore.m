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

- (void)save:(EEYEOIdObject *)object {
    [object setDirty:YES];
    NSError *error = nil;
    [context save:&error];
    if (error != nil) {
        NSLog(@"Error saving entity %@ with desc %@.  Error %@", [object class], [object objectID], [error description]);
    }
    return;
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
    if (error != nil) {
        NSLog(@"Error finding entityType %@ with id %@.  Error %@", entityType, withId, [error description]);
        return nil;
    }
    if (result == nil || [result count] == 0) {
        return nil;
    }
    if ([result count] > 1) {
        NSLog(@"Error finding entityType %@ with id %@.  Found more than 1 - %d", entityType, withId, [result count]);
        for (EEYEOIdObject *object in result) {
            NSLog(@"%@ %@", object.objectID, object.description);
        }
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
    NSDate *date = nil;

    EEYEOAppUser *appUser = [self findOrCreate:APPUSERENTITY withId:@"U1"];
    [appUser setActivated:YES];
    [appUser setActive:YES];
    [appUser setEmailAddress:@"test@test.com"];
    [appUser setFirstName:@"first"];
    [appUser setLastName:@"last"];
    [appUser setModificationTimestampFromNSDate:[NSDate dateWithTimeIntervalSince1970:0]];
    [appUser setLastLogout:[[NSDate dateWithTimeIntervalSince1970:0] timeIntervalSince1970]];
    [self save:appUser];

    EEYEOClassList *classList = [self findOrCreate:CLASSLISTENTITY withId:@"CL1"];
    [classList setName:@"A Class"];
    [classList setAppUser:appUser];
    [classList setModificationTimestamp:1];
    date = [NSDate dateWithTimeIntervalSinceNow:0];
    [classList setModificationTimestampFromNSDate:date];
    [self save:classList];

    NSMutableArray *categories = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 5; ++i) {
        NSMutableString *id = [[NSMutableString alloc] initWithString:@"OC"];
        [id appendFormat:@"%d", i];

        EEYEOObservationCategory *observationCategory = [self findOrCreate:CATEGORYENTITY withId:id];
        [observationCategory setShortName:id];
        [observationCategory setName:@"Observation Category"];
        [observationCategory setAppUser:appUser];
        date = [NSDate dateWithTimeIntervalSinceNow:0];
        [observationCategory setModificationTimestampFromNSDate:date];
        [self save:observationCategory];
        [categories addObject:observationCategory];
    }

    EEYEOStudent *student1 = [self findOrCreate:STUDENTENTITY withId:@"S1"];
    [student1 setFirstName:@"student"];
    [student1 setLastName:@"1"];
    [student1 addClassListsObject:classList];
    [student1 setAppUser:appUser];
    [student1 setModificationTimestamp:5];
    [self save:student1];

    EEYEOStudent *student2 = [self findOrCreate:STUDENTENTITY withId:@"S2"];
    [student2 setFirstName:@"student"];
    [student2 setLastName:@"2"];
    [student2 addClassListsObject:classList];
    [student2 setAppUser:appUser];
    [student2 setModificationTimestamp:5];
    [self save:student2];

    for (int i = 2; i < 51; ++i) {
        NSMutableString *id = [[NSMutableString alloc] initWithString:@"S"];
        [id appendFormat:@"%d", i];
        EEYEOStudent *student = [self findOrCreate:STUDENTENTITY withId:id];
        [student setFirstName:@"student"];
        [student setLastName:id];
        [student addClassListsObject:classList];
        [student setAppUser:appUser];
        [student setModificationTimestamp:5];
        [self save:student];
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
        [self save:observation];
    }
}


@end