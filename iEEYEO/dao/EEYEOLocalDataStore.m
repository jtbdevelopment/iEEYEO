//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "EEYEOLocalDataStore.h"
#import "EEYEOAppUser.h"
#import "EEYEODeletedObject.h"
#import "EEYEOObservation.h"
#import "EEYEOObservable.h"
#import "EEYEOStudent.h"
#import "EEYEOClassList.h"
#import "EEYEOObservationCategory.h"
#import "EEYEOPhoto.h"
#import "NSDateWithMillis.h"
#import "KeychainItemWrapper.h"


@implementation EEYEOLocalDataStore {
@private
    KeychainItemWrapper *_accountWrapper;
}

@synthesize context;

- (id)init {
    self = [super init];
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
            [_instance setAccountWrapper:[[KeychainItemWrapper alloc] initWithIdentifier:@"UserAccount" accessGroup:nil]];
        }
    }

    return _instance;
}

- (void)setAccountWrapper:(KeychainItemWrapper *)accountWrapper {
    _accountWrapper = accountWrapper;
}

- (void)setLogin:(NSString *)login {
    [_accountWrapper setObject:login forKey:(__bridge id) kSecAttrAccount];
}

- (NSString *)login {
    return [_accountWrapper objectForKey:(__bridge id) kSecAttrAccount];
}

- (EEYEOAppUser *)appUser {
    return [self findAppUserWithEmailAddress:[self login]];
}

- (void)setPassword:(NSString *)password {
    [_accountWrapper setObject:password forKey:(__bridge id) kSecValueData];
}

- (NSString *)password {
    return [_accountWrapper objectForKey:(__bridge id) kSecValueData];
}

- (void)setWebsite:(NSString *)url {
    [_accountWrapper setObject:url forKey:(__bridge id) kSecAttrService];
}

- (NSString *)website {
#if TARGET_IPHONE_SIMULATOR
    static NSString *const DEFAULT_REST_URL = @"https://Josephs-MacBook-Pro.local:8443/";
    static NSString *const OLD_DEFAULT_REST_URL = @"http://Josephs-MacBook-Pro.local:8080/REST/";
#else
    static NSString *const DEFAULT_REST_URL = @"https://www.e-eye-o.com/";
    static NSString *const OLD_DEFAULT_REST_URL = @"http://www.e-eye-o.com/REST/";
#endif

    NSString *url = [_accountWrapper objectForKey:(__bridge id) kSecAttrService];
    if ([url isEqualToString:@""]) {
        url = DEFAULT_REST_URL;
    }
    //  TODO - eliminate this at some point
    if ([url isEqualToString:OLD_DEFAULT_REST_URL]) {
        url = DEFAULT_REST_URL;
        [self setWebsite:DEFAULT_REST_URL];
    }
    return url;
}

- (void)saveToLocalStore:(EEYEOIdObject *)object {
    [object setDirty:YES];
    [object setModificationTimestampFromNSDateWithMillis:[[NSDateWithMillis alloc] init]];
    [self saveContext:object];
}

- (void)saveContext:(EEYEOIdObject *)object {
    NSError *error = nil;
    [context save:&error];
    if (error != nil) {
        if (object) {
            NSLog(@"Error saving entity %@ with desc %@.  Error %@", [object class], [object objectID], [error description]);
        } else {
            NSLog(@"Error saving context.  Error %@", [error description]);
        }
    }
}

- (void)clearAllItems {
    NSArray *objectTypes = [[NSArray alloc] initWithObjects:DELETEDENTITY, PHOTOENTITY, OBSERVATIONENTITY, STUDENTENTITY, CLASSLISTENTITY, CATEGORYENTITY, nil];
    for (NSString *type in objectTypes) {
        NSArray *entities = [self getEntitiesOfType:type WithPredicate:nil WithFetchLimit:0];
        for (EEYEOIdObject *object in entities) {
            [context deleteObject:object];
            [self saveContext:object];
        }
    }
}

- (void)deleteFromLocalStore:(EEYEOIdObject *)object {
    if (object.id && object.id.length > 0 && [object isKindOfClass:[EEYEOAppUserOwnedObject class]] && ![object isKindOfClass:[EEYEODeletedObject class]]) {
        EEYEODeletedObject *deleted = [self create:DELETEDENTITY];
        [deleted setDeletedId:[object id]];
        [deleted setAppUser:[[EEYEOLocalDataStore instance] appUser]];
        [self saveToLocalStore:deleted];
    }
    [self deleteUpdateFromRemoteStore:object];
}

- (void)updateFromRemoteStore:(EEYEOIdObject *)object {
    [object setDirty:NO];
    [self saveContext:object];
}

- (void)undoChanges {
    [context reset];
}

- (void)refreshObject:(EEYEOIdObject *)entity {
    [context refreshObject:entity mergeChanges:NO];
}

- (void)deleteUpdateFromRemoteStore:(EEYEOIdObject *)object {
    if ([object isKindOfClass:[EEYEOAppUserOwnedObject class]]) {
        EEYEOAppUserOwnedObject *owned = (EEYEOAppUserOwnedObject *) object;
        [[owned appUser] removeOwnedObjectsObject:owned];
        NSSet *photos = [[NSSet alloc] initWithSet:[owned photos]];
        for (EEYEOPhoto *photo in photos) {
            [[photo photoFor] removePhotosObject:photo];
            [context deleteObject:photo];
        }
    }

    if ([object isKindOfClass:[EEYEOObservation class]]) {
        EEYEOObservation *obs = (EEYEOObservation *) object;
        [[obs observable] removeObservationsObject:obs];
        NSSet *categories = [[NSSet alloc] initWithSet:[obs categories]];
        for (EEYEOObservationCategory *category in categories) {
            [category removeObservationsObject:obs];
        }
    }

    if ([object isKindOfClass:[EEYEOObservable class]]) {
        EEYEOObservable *observable = (EEYEOObservable *) object;
        NSSet *observations = [[NSSet alloc] initWithSet:[observable observations]];
        for (EEYEOObservation *observation in observations) {
            NSSet *categories = [[NSSet alloc] initWithSet:[observation categories]];
            for (EEYEOObservationCategory *category in categories) {
                [category removeObservationsObject:observation];
            }
            [[observation observable] removeObservationsObject:observation];
            [context deleteObject:observation];
        }
        [observable removeObservations:observations];
    }

    if ([object isKindOfClass:[EEYEOClassList class]]) {
        EEYEOClassList *classList = (EEYEOClassList *) object;
        NSSet *students = [[NSSet alloc] initWithSet:[classList photos]];
        for (EEYEOStudent *student in students) {
            [student removeClassListsObject:classList];
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
        [[photo photoFor] removePhotosObject:photo];
    }

    [context deleteObject:object];
    [self saveContext:object];
}

- (NSArray *)getDirtyEntities:(NSString *)entityType {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dirty = TRUE"];
    return [self getEntitiesOfType:entityType WithPredicate:predicate WithFetchLimit:0];
}

- (EEYEOIdObject *)getNextDirtyEntityOfType:(NSString *)entityType {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dirty = TRUE"];
    NSArray *results = [self getEntitiesOfType:entityType WithPredicate:predicate WithFetchLimit:1];
    if (results == nil || [results count] == 0) {
        return nil;
    }
    return [results objectAtIndex:0];
}

- (NSArray *)getEntitiesOfType:(NSString *)entityType WithPredicate:(NSPredicate *)predicate WithFetchLimit:(NSUInteger)fetchLimit {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityType inManagedObjectContext:context];
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    [request setFetchLimit:fetchLimit];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modificationTimestamp" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];

    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (error != nil) {
        NSLog(@"Error finding entityType %@.  Error %@", entityType, [error description]);
        return nil;
    }
    return result;
}

- (id)findAppUserWithEmailAddress:(NSString *)emailAddress {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:APPUSERENTITY inManagedObjectContext:context];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"emailAddress = %@", emailAddress];
    [request setPredicate:predicate];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];

    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (error != nil) {
        NSLog(@"Error finding appuser with email %@.  Error %@", emailAddress, [error description]);
        return nil;
    }
    if (result == nil || [result count] == 0) {
        return nil;
    }
    if ([result count] > 1) {
        NSLog(@"Error finding user with email %@.  Found more than 1 - %d", emailAddress, [result count]);
        for (EEYEOIdObject *object in result) {
            NSLog(@"%@ %@", object.objectID, object.description);
        }
    }
    return [result objectAtIndex:0];
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
    EEYEOIdObject *object = [NSEntityDescription insertNewObjectForEntityForName:entityType inManagedObjectContext:context];
    [object setModificationTimestampFromNSDateWithMillis:[NSDateWithMillis dateWithTimeIntervalFromNow:0]];
    [object setId:@""];
    return object;
}

- (id)findOrCreate:(NSString *)entityType withId:(NSString *)withId {
    id entity = [self find:entityType withId:withId];
    if (!entity) {
        entity = [self create:entityType];
        [(EEYEOIdObject *) entity setId:withId];
    }
    return entity;
}

@end