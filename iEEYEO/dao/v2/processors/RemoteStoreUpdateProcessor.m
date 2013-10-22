//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "RemoteStoreUpdateProcessor.h"
#import "EEYEOIdObject.h"
#import "NSDateWithMillis.h"
#import "EEYEOAppUserOwnedObject.h"
#import "EEYEORemoteDataStore.h"
#import "EEYEOLocalDataStore.h"
#import "EEYEODeletedObject.h"


@implementation RemoteStoreUpdateProcessor {

}
+ (NSDateWithMillis *)processUpdates:(id)unknownUpdates {
    static NSString *lock = @"RemoteStoreUpdateProcessor.LOCK";
    @synchronized (lock) {
        NSArray *updates;
        if ([unknownUpdates isKindOfClass:[NSDictionary class]]) {
            updates = [[NSArray alloc] initWithObjects:unknownUpdates, nil];
        } else {
            updates = unknownUpdates;
        }
        NSDateWithMillis *lastModTS = [[NSDateWithMillis alloc] init];
        for (NSDictionary *update in updates) {
            EEYEOIdObject *local = [self processJSONEntity:update];
            if (local) {
                NSDateWithMillis *modified = [local modificationTimestampToNSDateWithMillis];
                if ([modified compare:lastModTS] == NSOrderedDescending) {
                    lastModTS = modified;
                }
            }
        }
        return lastModTS;
    }
}

+ (id)processJSONEntity:(NSDictionary *)update {
    NSString *entityType = [update objectForKey:JSON_ENTITY];
    if ([entityType isEqualToString:JAVA_DELETED]) {
        return [self processDelete:update];
    } else {
        return [self processSaveOrUpdateFor:update OfType:entityType];
    }
}

+ (id)processSaveOrUpdateFor:(NSDictionary *)update OfType:(NSString *)entityType {
    //  TODO - this works under an assumptions which are wrong
    //    a.  That there are no active entities linked to archived entities
    //         (i.e. no active observation on an archived student)
    //         not always true with current server
    EEYEOLocalDataStore *localDataStore = [EEYEOLocalDataStore instance];
    NSString *localType = [[EEYEORemoteDataStore javaToIOSEntityMap] valueForKey:entityType];
    if (!localType) {
        return nil;
    }
    NSString *id = [update objectForKey:JSON_ID];
    EEYEOIdObject *local = [self getObjectToUpdateWithType:localType AndId:id];
    if (local.dirty) {
        NSDateWithMillis *remoteDate = [NSDateWithMillis dateFromJodaTime:[update valueForKey:JSON_MODIFICATIONTS]];
        NSComparisonResult result = [remoteDate compare:local.modificationTimestampToNSDateWithMillis];
        //
        //  TODO - revisit this in future
        //
        switch (result) {
            case NSOrderedSame:
            case NSOrderedDescending:
                break;
            case NSOrderedAscending:
                [localDataStore saveToLocalStore:local];
                return nil;
        }
    }
    if ([local loadFromDictionary:update]) {
        [localDataStore updateFromRemoteStore:local];
        if ([local isKindOfClass:[EEYEOAppUserOwnedObject class]] && [(EEYEOAppUserOwnedObject *) local archived]) {
            [localDataStore deleteUpdateFromRemoteStore:local];
        }
        return local;
    } else {
        [localDataStore undoChanges];
        //  TODO - maybe queue for re-processing
        return nil;
    }
}

+ (id)processDelete:(NSDictionary *)update {
    EEYEOLocalDataStore *localDataStore = [EEYEOLocalDataStore instance];
    EEYEODeletedObject *deletedObject = [localDataStore create:DELETEDENTITY];
    [deletedObject loadFromDictionary:update];
    EEYEOIdObject *local = [localDataStore find:APPUSEROWNEDENTITY withId:[deletedObject deletedId]];
    if (local) {
        [localDataStore deleteUpdateFromRemoteStore:local];
    }
    [localDataStore deleteUpdateFromRemoteStore:deletedObject];
    return local;
}

+ (id)getObjectToUpdateWithType:(NSString *)localType AndId:(NSString *)id {
    return [[EEYEOLocalDataStore instance] findOrCreate:localType withId:id];
}

@end