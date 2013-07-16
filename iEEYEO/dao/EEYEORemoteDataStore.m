//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "EEYEORemoteDataStore.h"
#import "EEYEOObservationCategory.h"
#import "EEYEOLocalDataStore.h"
#import "EEYEODeletedObject.h"


@implementation EEYEORemoteDataStore {
@private
    NSMutableData *_data;
    NSString *_currentUser;
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
        _data = [[NSMutableData alloc] init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if (![userDefaults stringForKey:USER_ID_KEY]) {
            //  TODO
            [userDefaults setObject:@"4028810e3f0758cf013f075939790000" forKey:USER_ID_KEY];
        }
        _currentUser = [userDefaults stringForKey:USER_ID_KEY];
        if (![userDefaults stringForKey:LAST_MODTS_KEY]) {
            [userDefaults setObject:@"2013-01-01" forKey:LAST_MODTS_KEY];
        }
        [userDefaults synchronize];
    }

    return self;
}

- (NSString *)lastModifiedURL {
    NSString *lastModificationFromServer = [[NSUserDefaults standardUserDefaults] stringForKey:LAST_MODTS_KEY];
    return [BASE_REST_USER_URL stringByAppendingFormat:@"%@/ModifiedSince/%@", _currentUser, lastModificationFromServer];
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self instance];
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

- (void)initializeFromRemoteServer {
    NSArray *objectTypes = [[NSArray alloc] initWithObjects:@"categories", @"classes", @"students", @"observations", @"photos", nil];
    [self authenticate:nil];
    for (NSString *type in objectTypes) {
        NSURL *url = [[NSURL alloc] initWithString:[BASE_REST_USER_URL stringByAppendingFormat:@"%@/%@/active", _currentUser, type]];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        [self processUpdatesFromServer:data];
    }
}

- (void)updateFromRemoteServer {
    NSURL *url = [[NSURL alloc] initWithString:[self lastModifiedURL]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection) {
        //  TODO
        NSLog(@"Failed");
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //  TODO
    NSLog(@"Failed with error %@", error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //  TODO - only received on authentication failure
    if ([[response MIMEType] isEqualToString:@"text/html"]) {
        NSLog(@"Cancelling due to html type");
        NSURLRequest *currentRequest = [connection currentRequest];
        [connection cancel];
        [self authenticate:currentRequest];

    } else {
        [_data setLength:0];
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
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self processUpdatesFromServer:_data];
}

- (void)processUpdatesFromServer:(NSData *)data {
    NSError *error;
    NSArray *updates = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"%@", updates);
    EEYEOLocalDataStore *localDataStore = [EEYEOLocalDataStore instance];
    for (NSDictionary *update in updates) {
        NSString *entityType = [update objectForKey:JSON_ENTITY];
        if ([entityType isEqualToString:JAVA_DELETED]) {
            EEYEODeletedObject *deletedObject = [[EEYEODeletedObject alloc] init];
            [deletedObject loadFromDictionary:update];
            EEYEOIdObject *local = [localDataStore find:APPUSEROWNEDENTITY withId:[deletedObject deletedId]];
            if (local) {
                NSLog(@"Deleting %@", [deletedObject deletedId]);
                [localDataStore deleteUpdateFromRemoteStore:local];
            } else {
                NSLog(@"Deleted Id %@ not found locally - probably ok", [deletedObject deletedId]);
            }

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
        }
    }
}


@end