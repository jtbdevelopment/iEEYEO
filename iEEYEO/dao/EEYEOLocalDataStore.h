//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class EEYEOIdObject;
@class EEYEORemoteDataStore;
@class EEYEOAppUser;


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

- (void)setLogin:(NSString *)login;

- (EEYEOAppUser *)appUser;

- (NSString *)login;

- (void)setPassword:(NSString *)password;

- (NSString *)password;

- (void)setWebsite:(NSString *)url;

- (NSString *)website;

- (void)saveToLocalStore:(EEYEOIdObject *)object;

- (void)clearAllItems;

- (void)deleteFromLocalStore:(EEYEOIdObject *)object;

- (void)updateFromRemoteStore:(EEYEOIdObject *)object;

- (void)undoChanges;

- (void)deleteUpdateFromRemoteStore:(EEYEOIdObject *)object;

- (NSArray *)getDirtyEntities:(NSString *)entityType;

- (NSArray *)getEntitiesOfType:(NSString *)entityType WithPredicate:(NSPredicate *)predicate;

- (id)findAppUserWithEmailAddress:(NSString *)emailAddress;

- (id)find:(NSString *)entityType withId:(NSString *)withId;

- (id)create:(NSString *)entityType;

- (id)findOrCreate:(NSString *)entityType withId:(NSString *)withId;

@end