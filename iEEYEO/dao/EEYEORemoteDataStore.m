//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "EEYEORemoteDataStore.h"
#import "EEYEOObservationCategory.h"
#import "EEYEOLocalDataStore.h"
#import "EEYEODeletedObject.h"
#import "EEYEOClassList.h"


@implementation EEYEORemoteDataStore {
@private
    NSString *_currentUser;
    NSDateFormatter *_dateFormatter;
    NSMutableDictionary *_connectionDataMap;
    int _requestCounter;
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


        _requestCounter = 0;

        _connectionDataMap = [[NSMutableDictionary alloc] init];

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
        [self authenticate:nil];
        for (NSString *type in objectTypes) {
            NSURL *url = [[NSURL alloc] initWithString:[[self getUserURL] stringByAppendingFormat:@"%@/active", type]];
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
            NSURLResponse *response;
            NSError *error;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            [self processUpdatesFromServer:data];
        }
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

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //  TODO
    NSLog(@"Failed with error %@", error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpurlResponse = (NSHTTPURLResponse *) response;
    if ([httpurlResponse statusCode] == 201) {
        NSString *newURL = [[httpurlResponse allHeaderFields] valueForKey:@"Location"];
    }

    //  only received on authentication failure
    if ([[response MIMEType] isEqualToString:@"text/html"]) {
        NSLog(@"Cancelling due to html type");
        NSURLRequest *currentRequest = [connection currentRequest];
        [connection cancel];
        @synchronized (_connectionDataMap) {
            NSString *key = [[connection currentRequest] valueForHTTPHeaderField:COUNTER_KEY];
            if ([_connectionDataMap objectForKey:key]) {
                [_connectionDataMap removeObjectForKey:key];
            }
        }
        [self authenticate:currentRequest];
    } else {
        NSMutableData *data = [[NSMutableData alloc] init];
        @synchronized (_connectionDataMap) {
            [_connectionDataMap setValue:data forKey:[[connection originalRequest] valueForHTTPHeaderField:COUNTER_KEY]];
        }
    }
}

- (void)authenticate:(NSURLRequest *)currentRequest {
    NSURL *url = [[NSURL alloc] initWithString:[BASE_REST_URL stringByAppendingString:@"security/login?_spring_security_remember_me=true"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    //  TODO
    NSString *form = @"login=x@x&password=xx&_spring_security_remember_me=true";
    char const *bytes = [form UTF8String];
    [request setHTTPBody:[NSData dataWithBytes:bytes length:[form length]]];
    NSURLResponse *response;
    NSError *error;
    NSData *loginData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if ([response.MIMEType isEqualToString:@"text/plain"]) {
        NSString *string = [[NSString alloc] initWithData:loginData encoding:NSUTF8StringEncoding];
        if ([string isEqualToString:@"SUCCESS"]) {
            if (currentRequest) {
                NSLog(@"Login success - resending request");
                NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:currentRequest delegate:self];
                if (!connection) {
                    //  TODO
                    NSLog(@"Failed");
                }
            } else {
                NSLog(@"Nil currentRequest");
                return;
            }
        } else {
            //  TODO
            NSLog(@"Failure");
        }
    } else {
        //  TODO
        NSLog(@"Got unexpected login mimetype:%@", [response MIMEType]);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSMutableData *dataStore;
    @synchronized (self) {
        dataStore = [_connectionDataMap objectForKey:[[connection originalRequest] valueForHTTPHeaderField:COUNTER_KEY]];
    }
    [dataStore appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSMutableData *data;
    @synchronized (self) {
        NSString *key = [[connection originalRequest] valueForHTTPHeaderField:COUNTER_KEY];
        data = [_connectionDataMap objectForKey:key];
        [_connectionDataMap removeObjectForKey:key];
    }
    [self processUpdatesFromServer:data];
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
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection) {
        //  TODO
        NSLog(@"Failed");
    }
}

- (void)deleteFromServer:(EEYEODeletedObject *)deleted {

}

- (void)processUpdatesFromServer:(NSData *)data {
    NSError *error;
    NSArray *updates = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"%@", updates);
    EEYEOLocalDataStore *localDataStore = [EEYEOLocalDataStore instance];
    NSDate *lastModTS = [self getLastUpdateFromServerAsNSDate];
    for (NSDictionary *update in updates) {
        NSString *entityType = [update objectForKey:JSON_ENTITY];
        if ([entityType isEqualToString:JAVA_DELETED]) {
            EEYEODeletedObject *deletedObject = [localDataStore create:DELETEDENTITY];
            [deletedObject loadFromDictionary:update];
            EEYEOIdObject *local = [localDataStore find:APPUSEROWNEDENTITY withId:[deletedObject deletedId]];
            if (local) {
                NSLog(@"Deleting %@", [deletedObject deletedId]);
                [localDataStore deleteUpdateFromRemoteStore:local];
            } else {
                NSLog(@"Deleted Id %@ not found locally - probably ok", [deletedObject deletedId]);
            }
            [localDataStore deleteUpdateFromRemoteStore:deletedObject];
        } else {
            NSString *localType = [[EEYEORemoteDataStore javaToIOSEntityMap] valueForKey:entityType];
            if (!localType) {
                NSLog(@"Unknown entity type %@", entityType);
                continue;
            }
            NSString *id = [update objectForKey:JSON_ID];
            EEYEOIdObject *local = [localDataStore findOrCreate:localType withId:id];
            if (local.dirty) {
                NSDate *remoteDate = [EEYEOIdObject fromJodaDateTime:[update valueForKey:JSON_MODIFICATIONTS]];
                NSComparisonResult result = [remoteDate compare:local.modificationTimestampToNSDate];
                switch (result) {
                    case NSOrderedAscending:
                        NSLog(@"Remote more recent - take it");
                        break;
                    case NSOrderedDescending:
                        NSLog(@"Local more recent - skip remote and remark local as dirty");
                        [localDataStore saveToLocalStore:local];
                        continue;
                    case NSOrderedSame:
                        NSLog(@"Virtually impossible");
                        break;
                }
                //  TODO
                NSLog(@"Conflict");
            }
            [local loadFromDictionary:update];
            [localDataStore updateFromRemoteStore:local];
            if ([local isKindOfClass:[EEYEOAppUserOwnedObject class]] && [(EEYEOAppUserOwnedObject *) local archived]) {
                [localDataStore deleteUpdateFromRemoteStore:local];
            } else {
                NSMutableDictionary *rewrite = [[NSMutableDictionary alloc] init];
                [local writeToDictionary:rewrite];
                NSLog(@"%@", update);
                NSLog(@"%@", rewrite);
            }
            NSDate *modified = [local modificationTimestampToNSDate];
            if ([modified compare:lastModTS] == NSOrderedDescending) {
                lastModTS = modified;
            }
        }
    }
    [self setLastUpdateFromServerWithNSDate:lastModTS];
}

@end