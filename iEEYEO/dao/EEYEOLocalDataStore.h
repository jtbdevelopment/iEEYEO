//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class EEYEOIdObject;


static NSString *const APPUSERENTITY = @"EEYEOAppUser";

static NSString *const CLASSLISTENTITY = @"EEYEOClassList";

static NSString *const CATEGORYENTITY = @"EEYEOObservationCategory";

static NSString *const STUDENTENTITY = @"EEYEOStudent";

static NSString *const OBSERVATIONENTITY = @"EEYEOObservation";

static NSString *const OBSERVABLEENTITY = @"EEYEOObservable";

@interface EEYEOLocalDataStore : NSObject {

}

@property(nonatomic, retain) NSManagedObjectContext *context;
@property(nonatomic, retain) NSManagedObjectModel *model;

+ (EEYEOLocalDataStore *)instance;

- (void)save:(EEYEOIdObject *)object;

- (id)find:(NSString *)entityType withId:(NSString *)withId;

- (void)createDummyData;
@end