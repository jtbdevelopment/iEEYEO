//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>

@class BaseRESTDelegate;
@class EEYEOIdObject;
@class NSDateWithMillis;

static NSString *const LAST_MODTS_KEY = @"LAST_SERVER_MODTS";
static NSString *const LAST_MODTSMILLIS_KEY = @"LAST_SERVER_MODTSMILLIS";
static NSString *const LAST_RESYNC_KEY = @"LAST_SERVER_RESYNC";
static NSString *const LAST_RESYNCMILLIS_KEY = @"LAST_SERVER_RESYNCMILLIS";

static NSString *const JAVA_CATEGORY = @"com.jtbdevelopment.e_eye_o.entities.ObservationCategory";
static NSString *const JAVA_OBSERVATION = @"com.jtbdevelopment.e_eye_o.entities.Observation";
static NSString *const JAVA_CLASSLIST = @"com.jtbdevelopment.e_eye_o.entities.ClassList";
static NSString *const JAVA_STUDENT = @"com.jtbdevelopment.e_eye_o.entities.Student";
static NSString *const JAVA_PHOTO = @"com.jtbdevelopment.e_eye_o.entities.Photo";
static NSString *const JAVA_USER = @"com.jtbdevelopment.e_eye_o.entities.AppUser";
static NSString *const JAVA_DELETED = @"com.jtbdevelopment.e_eye_o.entities.DeletedObject";

static NSString *const REFRESH_FREQUENCY_KEY = @"REFRESH_FREQUENCY";

@interface EEYEORemoteDataStore : NSObject
+ (EEYEORemoteDataStore *)instance;

+ (NSDictionary *)javaToIOSEntityMap;

+ (NSDictionary *)iosToJavaEntityMap;

- (void)haltRemoteSyncs;

- (void)startRemoteSyncs;

- (void)stopTimer;

- (void)startTimer;

- (void)resetTimer;

- (void)requeueWorkItem:(BaseRESTDelegate *)delegate;

- (void)completeWorkItem:(BaseRESTDelegate *)delegate;

- (void)addWorkItem:(BaseRESTDelegate *)delegate;

- (NSString *)userURL;

- (NSString *)entityURLForObject:(EEYEOIdObject *)entity;

- (NSString *)entityURLForId:(NSString *)entity;

- (NSString *)lastServerResyncAsString;

- (void)setLastUpdateFromServerWithNSDateWithMillis:(NSDateWithMillis *)value;

- (NSString *)lastUpdateFromServerAsString;

- (NSDateWithMillis *)lastUpdateFromServerAsNSDateWithMillis;

- (void)setRefreshFrequency:(int)frequency;

- (int)refreshFrequency;

- (void)initializeFromRemoteServer;

- (void)initializeUsersFromRemoteServer;

- (NSURLRequest *)generateUserLoadRequest;

- (void)resyncWithRemoteServer;

@end