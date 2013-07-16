//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class EEYEOIdObject;
@class EEYEORemoteDataStore;


static NSString *const APPUSERENTITY = @"EEYEOAppUser";

static NSString *const APPUSEROWNEDENTITY = @"EEYEOAppUserOwnedObject";

static NSString *const CLASSLISTENTITY = @"EEYEOClassList";

static NSString *const CATEGORYENTITY = @"EEYEOObservationCategory";

static NSString *const DELETEDENTITY = @"EEYEODeletedObject";

static NSString *const PHOTOENTITY = @"EEYEOPhoto";

static NSString *const STUDENTENTITY = @"EEYEOStudent";

static NSString *const OBSERVATIONENTITY = @"EEYEOObservation";

static NSString *const OBSERVABLEENTITY = @"EEYEOObservable";

@interface EEYEOLocalDataStore : NSObject {

}

@property(nonatomic, retain) NSManagedObjectContext *context;
@property(nonatomic, retain) NSManagedObjectModel *model;

+ (EEYEOLocalDataStore *)instance;

- (void)saveToLocalStore:(EEYEOIdObject *)object;

- (void)deleteFromLocalStore:(EEYEORemoteDataStore *)object;

- (void)updateFromRemoteStore:(EEYEOIdObject *)object;

- (void)deleteUpdateFromRemoteStore:(EEYEOIdObject *)object;

- (id)find:(NSString *)entityType withId:(NSString *)withId;

- (id)create:(NSString *)entityType;

- (id)findOrCreate:(NSString *)entityType withId:(NSString *)withId;

- (void)createDummyData;
@end