//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "EEYEOLocalDataStore.h"
#import "EEYEOAppUser.h"
#import "EEYEORemoteDataStore.h"
#import "EEYEODeletedObject.h"
#import "EEYEOObservation.h"
#import "EEYEOObservable.h"
#import "EEYEOStudent.h"
#import "EEYEOClassList.h"
#import "EEYEOObservationCategory.h"
#import "EEYEOPhoto.h"


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

- (void)saveToLocalStore:(EEYEOIdObject *)object {
    [object setDirty:YES];
    [self saveContext:object];
}

- (void)saveContext:(EEYEOIdObject *)object {
    NSError *error = nil;
    [context save:&error];
    if (error != nil) {
        NSLog(@"Error saving entity %@ with desc %@.  Error %@", [object class], [object objectID], [error description]);
    }
}

- (void)deleteFromLocalStore:(EEYEOIdObject *)object {
    //  TODO - put on list to send back to remote server
    if (object.id && object.id.length > 0) {
        EEYEODeletedObject *deleted = [self create:DELETEDENTITY];
        [deleted setDeletedId:[object id]];
        [self saveToLocalStore:deleted];
    }
    [self deleteUpdateFromRemoteStore:object];
}

- (void)updateFromRemoteStore:(EEYEOIdObject *)object {
    [object setDirty:NO];
    [self saveContext:object];
}

- (void)deleteUpdateFromRemoteStore:(EEYEOIdObject *)object {
    if ([object isKindOfClass:[EEYEOAppUserOwnedObject class]]) {
        EEYEOAppUserOwnedObject *owned = (EEYEOAppUserOwnedObject *) object;
        [[owned appUser] removeOwnedObjectsObject:owned];
    }
    if ([object isKindOfClass:[EEYEOObservation class]]) {
        EEYEOObservation *obs = (EEYEOObservation *) object;
        [[obs observable] removeObservationsObject:obs];
        NSSet *categories = [[NSSet alloc] initWithSet:[obs categories]];
        for (EEYEOObservationCategory *category in categories) {
            [category removeObservationsObject:obs];
        }
    }
    if ([object isKindOfClass:[EEYEOStudent class]]) {
        EEYEOStudent *student = (EEYEOStudent *) object;
        NSSet *classes = [[NSSet alloc] initWithSet:[student classLists]];
        for (EEYEOClassList *classList in classes) {
            [classList removeStudentsObject:student];
        }
    }
    if ([object isKindOfClass:[EEYEOPhoto class]]) {
        EEYEOPhoto *photo = (EEYEOPhoto *) object;
        [[photo photoFor] removePhotos:photo];
    }
    [context deleteObject:object];
    [self saveContext:object];
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
    EEYEOAppUser *appUser = [self findOrCreate:APPUSERENTITY withId:@"4028810e3f0758cf013f075939790000"];
    [appUser setActivated:YES];
    [appUser setActive:YES];
    [appUser setEmailAddress:@"test@test.com"];
    [appUser setFirstName:@"first"];
    [appUser setLastName:@"last"];
    [appUser setModificationTimestampFromNSDate:[NSDate dateWithTimeIntervalSince1970:0]];
    [appUser setLastLogout:[[NSDate dateWithTimeIntervalSince1970:0] timeIntervalSince1970]];
    [self saveToLocalStore:appUser];

    [[EEYEORemoteDataStore instance] initializeFromRemoteServer];
}


@end