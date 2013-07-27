//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "EEYEORemoteDataStore.h"
#import "EEYEOObservationCategory.h"
#import "EEYEOLocalDataStore.h"
#import "BaseRESTDelegate.h"
#import "UpdatesFromServerRESTDelegate.h"
#import "RESTWriter.h"
#import "NSDateWithMillis.h"


@implementation EEYEORemoteDataStore {
@private
    NSMutableArray *_workQueue;
    BaseRESTDelegate *_currentWorkItem;

    NSString *_currentUser;
    NSDateFormatter *_dateFormatter;
    NSNumberFormatter *_numberFormatter;

    RESTWriter *_restWriter;
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
        //  TODO - support photos
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

        _numberFormatter = [[NSNumberFormatter alloc] init];
        //  TODO??
        //[_dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:@"GMT"]];

        _currentWorkItem = nil;
        _workQueue = [[NSMutableArray alloc] init];

        _restWriter = [[RESTWriter alloc] initForRemoteStore:self];

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if (![userDefaults stringForKey:USER_ID_KEY]) {
            //  TODO
            [userDefaults setObject:@"4028810e3f0758cf013f075939790000" forKey:USER_ID_KEY];
            [userDefaults synchronize];
        }
        _currentUser = [userDefaults stringForKey:USER_ID_KEY];
        if ([[self getLastUpdateFromServer] count] == 0) {
            [self setLastUpdateFromServerWithNSDateWithMillis:[[NSDateWithMillis alloc] init]];
        }
    }

    return self;
}

- (void)requeueWorkItem:(BaseRESTDelegate *)delegate {
    //  TODO - infinite loop check
    @synchronized (self) {
        if (delegate != _currentWorkItem) {
            NSLog(@"Current work item not same as completed - how did this happen");
        }
        [_workQueue insertObject:delegate atIndex:0];
        [self submitNextWorkItem];
    }
}

- (void)completeWorkItem:(BaseRESTDelegate *)delegate {
    @synchronized (self) {
        if (delegate != _currentWorkItem) {
            NSLog(@"Current work item not same as completed - how did this happen");
        }
        [self submitNextWorkItem];
    }
}

- (void)addWorkItem:(BaseRESTDelegate *)delegate {
    @synchronized (self) {
        [_workQueue addObject:delegate];
        if (!_currentWorkItem) {
            [self submitNextWorkItem];
        }
    }
}

//  Expected to be called from function that is already synchronized
- (void)submitNextWorkItem {
    _currentWorkItem = nil;
    //  TODO - check internet access
    //  TODO - add something to kick off requests periodically if no internet
    if ([_workQueue count] > 0) {
        _currentWorkItem = [_workQueue objectAtIndex:0];
        [_workQueue removeObjectAtIndex:0];
        [_currentWorkItem submitRequest];
    }
}

- (NSString *)getUserURL {
    return [BASE_REST_USER_URL stringByAppendingFormat:@"%@/", _currentUser];
}

- (NSString *)getEntityURLFromEntity:(EEYEOIdObject *)entity {
    return [self getEntityURL:[entity id]];
}

- (NSString *)getEntityURL:(NSString *)id {
    return [[self getUserURL] stringByAppendingFormat:@"%@/", id];

}

- (NSString *)lastModifiedURL {
    NSString *lastModificationFromServer = [self getLastUpdateFromServerAsString];
    return [BASE_REST_USER_URL stringByAppendingFormat:@"%@/ModifiedSince/%@", _currentUser, lastModificationFromServer];
}

- (void)setLastUpdateFromServerWithNSDateWithMillis:(NSDateWithMillis *)value {
    @synchronized (self) {
        NSDateWithMillis *currentValue = [self getLastUpdateFromServerAsNSDateWithMillis];
        if ([currentValue compare:value] != NSOrderedAscending) {
            return;
        }
        NSMutableArray *strings = [[NSMutableArray alloc] init];
        [strings addObject:[_dateFormatter stringFromDate:[value date]]];
        [strings addObject:[_numberFormatter stringFromNumber:[[NSNumber alloc] initWithInt:[value millis]]]];
        [self setLastUpdateFromServer:strings];
    }
}

- (void)setLastUpdateFromServer:(NSArray *)values {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[values objectAtIndex:0] forKey:LAST_MODTS_KEY];
    [defaults setObject:[values objectAtIndex:1] forKey:LAST_MODTSMILLIS_KEY];
    [defaults synchronize];
}

- (NSString *)getLastUpdateFromServerAsString {
    NSDateWithMillis *dateWithMillis = [self getLastUpdateFromServerAsNSDateWithMillis];
    NSString *string = [_dateFormatter stringFromDate:[dateWithMillis date]];
    return [string stringByAppendingFormat:@".%03d", [dateWithMillis millis]];
}

- (NSDateWithMillis *)getLastUpdateFromServerAsNSDateWithMillis {
    NSArray *strings = [self getLastUpdateFromServer];
    if ([strings count] > 0) {
        return [[NSDateWithMillis alloc] initWithNSDate:[_dateFormatter dateFromString:[strings objectAtIndex:0]] AndMillis:[[_numberFormatter numberFromString:[strings objectAtIndex:1]] intValue]];
    } else {
        return [[NSDateWithMillis alloc] init];
    }
}

- (NSArray *)getLastUpdateFromServer {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:LAST_MODTS_KEY];
    if (value) {
        [array addObject:value];
        [array addObject:[[NSUserDefaults standardUserDefaults] stringForKey:LAST_MODTSMILLIS_KEY]];
    }
    return array;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self instance];
}

- (void)initializeFromRemoteServer {
    NSArray *objectTypes = [[NSArray alloc] initWithObjects:@"categories", @"classes", @"students", @"observations", @"photos", nil];
    for (NSString *type in objectTypes) {
        NSURL *url = [[NSURL alloc] initWithString:[[self getUserURL] stringByAppendingFormat:@"%@/active", type]];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [self addWorkItem:[[BaseRESTDelegate alloc] initWithRequest:request]];
    }
}

- (void)resyncWithRemoteServer {
    //  TODO - prevent multiple items queued - better?
    @synchronized (self) {
        if ([_workQueue count] > 0) {
            return;
        }
        [self updateFromRemoteServer];

        NSArray *objectTypes = [[NSArray alloc] initWithObjects:CATEGORYENTITY, CLASSLISTENTITY, STUDENTENTITY, OBSERVATIONENTITY, PHOTOENTITY, DELETEDENTITY, nil];
        for (NSString *type in objectTypes) {
            NSArray *dirtyEntities = [[EEYEOLocalDataStore instance] getDirtyEntities:type];
            for (EEYEOIdObject *entity in dirtyEntities) {
                [_restWriter saveEntityToRemote:entity];
            }
        }
        //  TODO - this actually requests same modified timestamp as previous call - works but a hack
        [self updateFromRemoteServer];
    }
}

- (void)updateFromRemoteServer {
    NSURL *url = [[NSURL alloc] initWithString:[self lastModifiedURL]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [self addWorkItem:[[UpdatesFromServerRESTDelegate alloc] initWithRequest:request]];
}

@end