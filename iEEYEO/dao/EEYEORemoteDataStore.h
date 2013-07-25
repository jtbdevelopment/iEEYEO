//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>

@class BaseRESTDelegate;
@class EEYEOIdObject;

static NSString *const BASE_REST_URL = @"http://Josephs-MacBook-Pro.local:8080/REST/";
static NSString *const BASE_REST_USER_URL = @"http://Josephs-MacBook-Pro.local:8080/REST/users/";

static NSString *const USER_ID_KEY = @"userId";

static NSString *const LAST_MODTS_KEY = @"LAST_SERVER_MODTS";

static NSString *const JAVA_CATEGORY = @"com.jtbdevelopment.e_eye_o.entities.ObservationCategory";
static NSString *const JAVA_OBSERVATION = @"com.jtbdevelopment.e_eye_o.entities.Observation";
static NSString *const JAVA_CLASSLIST = @"com.jtbdevelopment.e_eye_o.entities.ClassList";
static NSString *const JAVA_STUDENT = @"com.jtbdevelopment.e_eye_o.entities.Student";
static NSString *const JAVA_PHOTO = @"com.jtbdevelopment.e_eye_o.entities.Photo";
static NSString *const JAVA_USER = @"com.jtbdevelopment.e_eye_o.entities.AppUser";
static NSString *const JAVA_DELETED = @"com.jtbdevelopment.e_eye_o.entities.DeletedObject";

static NSString *const INITIAL_LAST_UPDATETS = @"2013-01-01T00:00:00";

@interface EEYEORemoteDataStore : NSObject
+ (EEYEORemoteDataStore *)instance;

+ (NSDictionary *)javaToIOSEntityMap;

+ (NSDictionary *)iosToJavaEntityMap;

- (void)requeueWorkItem:(BaseRESTDelegate *)delegate;

- (void)completeWorkItem:(BaseRESTDelegate *)delegate;

- (void)addWorkItem:(BaseRESTDelegate *)delegate;

- (NSString *)getUserURL;

- (NSString *)getEntityURLFromEntity:(EEYEOIdObject *)entity;

- (NSString *)getEntityURL:(NSString *)entity;

- (void)setLastUpdateFromServerWithNSDate:(NSDate *)value;

- (NSDate *)getLastUpdateFromServerAsNSDate;

- (void)initializeFromRemoteServer;

- (void)resyncWithRemoteServer;

@end