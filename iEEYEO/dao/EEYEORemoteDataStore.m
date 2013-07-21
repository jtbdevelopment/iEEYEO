//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "EEYEORemoteDataStore.h"
#import "EEYEOObservationCategory.h"
#import "EEYEOLocalDataStore.h"
#import "EEYEODeletedObject.h"
#import "EEYEOClassList.h"
#import "BaseRESTDelegate.h"


@implementation EEYEORemoteDataStore {
@private
    NSString *_currentUser;
    NSDateFormatter *_dateFormatter;
}

+ (EEYEORemoteDataStore *)instance {
    static EEYEORemoteDataStore *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[super allocWithZone:nil] init];
        }
    }

    return _instance;
}

+ (NSDictionary *)javaToIOSEntityMap {
    static NSDictionary *map;
    if (!map) {
        map = [[NSMutableDictionary alloc] init];
        [map setValue:OBSERVATIONENTITY forKey:JAVA_OBSERVATION];
        [map setValue:CATEGORYENTITY forKey:JAVA_CATEGORY];
        [map setValue:STUDENTENTITY forKey:JAVA_STUDENT];
        [map setValue:CLASSLISTENTITY forKey:JAVA_CLASSLIST];
//        [map setValue:PHOTOENTITY forKey:JAVA_PHOTO];
        [map setValue:APPUSERENTITY forKey:JAVA_USER];
        map = [[NSDictionary alloc] initWithDictionary:map];
    }
    return map;
}

+ (NSDictionary *)iosToJavaEntityMap {
    static NSDictionary *map;
    if (!map) {
        NSDictionary *javaToIOS = [EEYEORemoteDataStore javaToIOSEntityMap];
        map = [[NSMutableDictionary alloc] init];
        [javaToIOS enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
            [map setValue:key forKey:object];
        }];
        map = [[NSDictionary alloc] initWithDictionary:map];
    }
    return map;
}

- (id)init {
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];

        //  TODO??
        //[_dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:@"GMT"]];


        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if (![userDefaults stringForKey:USER_ID_KEY]) {
            //  TODO
            [userDefaults setObject:@"4028810e3f0758cf013f075939790000" forKey:USER_ID_KEY];
            [userDefaults synchronize];
        }
        _currentUser = [userDefaults stringForKey:USER_ID_KEY];
        if (![self getLastUpdateFromServer]) {
            [self setLastUpdateFromServer:INITIAL_LAST_UPDATETS];
        }
    }

    return self;
}

- (NSString *)getUserURL {
    return [BASE_REST_USER_URL stringByAppendingFormat:@"%@/", _currentUser];
}

- (NSString *)lastModifiedURL {
    NSString *lastModificationFromServer = [self getLastUpdateFromServer];
    return [BASE_REST_USER_URL stringByAppendingFormat:@"%@/ModifiedSince/%@", _currentUser, lastModificationFromServer];
}

- (void)setLastUpdateFromServerWithNSDate:(NSDate *)value {
    [self setLastUpdateFromServer:[_dateFormatter stringFromDate:value]];
}

- (void)setLastUpdateFromServer:(NSString *)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:LAST_MODTS_KEY];
    [defaults synchronize];
}

- (NSDate *)getLastUpdateFromServerAsNSDate {
    NSString *string = [self getLastUpdateFromServer];
    return [_dateFormatter dateFromString:string];
}

- (NSString *)getLastUpdateFromServer {
    return [[NSUserDefaults standardUserDefaults] stringForKey:LAST_MODTS_KEY];
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self instance];
}

- (void)initializeFromRemoteServer {
    @synchronized (self) {
        NSArray *objectTypes = [[NSArray alloc] initWithObjects:@"categories", @"classes", @"students", @"observations", @"photos", nil];
        // Force authentication
        [BaseRESTDelegate authenticateAndRerequest:nil];
        for (NSString *type in objectTypes) {
            NSURL *url = [[NSURL alloc] initWithString:[[self getUserURL] stringByAppendingFormat:@"%@/active", type]];
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
            NSURLResponse *response;
            NSError *error;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            [BaseRESTDelegate processUpdatesFromServer:data];
        }

        //  TODO - eliminate
        EEYEOClassList *list = (EEYEOClassList *) [[EEYEOLocalDataStore instance] create:CLASSLISTENTITY];
        [list setAppUser:[[EEYEOLocalDataStore instance] find:APPUSERENTITY withId:_currentUser]];
        [list setName:@"Create Test"];
        [list setId:@""];
        [[EEYEOLocalDataStore instance] saveToLocalStore:list];
        [self createToServer:list];
    }
}

- (void)updateFromRemoteServer {
/*
    @synchronized (self) {
        NSURL *url = [[NSURL alloc] initWithString:[self lastModifiedURL]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        NSString *value = [[NSString alloc] initWithFormat:@"%d", _requestCounter];
        [request setValue:value forHTTPHeaderField:COUNTER_KEY];
        _requestCounter++;
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (!connection) {
            //  TODO
            NSLog(@"Failed");
        }
    }
    */
}

- (void)saveToServer:(EEYEOIdObject *)object {
    if ([object isKindOfClass:[EEYEODeletedObject class]]) {
        return [self deleteFromServer:(EEYEODeletedObject *) object];
    }
    if ([[object id] isEqualToString:@""]) {
        return [self createToServer:object];
    }
    return [self updateToServer:object];
}

- (void)updateToServer:(EEYEOIdObject *)updated {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [updated writeToDictionary:dictionary];


}

- (void)createToServer:(EEYEOIdObject *)created {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [created writeToDictionary:dictionary];
    NSURL *url = [[NSURL alloc] initWithString:[self getUserURL]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    NSError *error;
    NSOutputStream *stream = [[NSOutputStream alloc] initToMemory];
    [stream open];
    [NSJSONSerialization writeJSONObject:dictionary toStream:stream options:NSJSONWritingPrettyPrinted error:&error];
    [stream close];
    NSData *streamData = [stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    NSString *form = [[NSString alloc] initWithFormat:@"appUserOwnedObject=%@", [[NSString alloc] initWithData:streamData encoding:NSASCIIStringEncoding]];
    char const *bytes = [form UTF8String];
    [request setHTTPBody:[NSData dataWithBytes:bytes length:[form length]]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:[[BaseRESTDelegate alloc] initWithRequest:request]];
    if (!connection) {
        //  TODO
        NSLog(@"Failed");
    }
}

- (void)deleteFromServer:(EEYEODeletedObject *)deleted {

}
@end