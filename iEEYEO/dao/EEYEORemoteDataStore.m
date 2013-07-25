//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "EEYEORemoteDataStore.h"
#import "EEYEOObservationCategory.h"
#import "EEYEOLocalDataStore.h"
#import "EEYEODeletedObject.h"
#import "BaseRESTDelegate.h"
#import "UpdatesFromServerRESTDelegate.h"
#import "CreationRESTDelegate.h"


@implementation EEYEORemoteDataStore {
@private
    NSMutableArray *_workQueue;
    BaseRESTDelegate *_currentWorkItem;

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

        _currentWorkItem = nil;
        _workQueue = [[NSMutableArray alloc] init];

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

- (NSString *)getEntityURL:(EEYEOIdObject *)entity {
    return [[self getUserURL] stringByAppendingFormat:@"%@/", [entity id]];
}

- (NSString *)lastModifiedURL {
    NSString *lastModificationFromServer = [self getLastUpdateFromServer];
    return [BASE_REST_USER_URL stringByAppendingFormat:@"%@/ModifiedSince/%@", _currentUser, lastModificationFromServer];
}

//  TODO - really need this to be at subsecond level for all timestamp fields
- (void)setLastUpdateFromServerWithNSDate:(NSDate *)value {
    @synchronized (self) {
        NSDate *currentValue = [self getLastUpdateFromServerAsNSDate];
        if ([currentValue compare:value] != NSOrderedAscending) {
            NSLog(@"Skipping update timestamp of %@ as not greater than %@", value, currentValue);
            return;
        }
        [self setLastUpdateFromServer:[_dateFormatter stringFromDate:value]];
    }
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
    NSArray *objectTypes = [[NSArray alloc] initWithObjects:@"categories", @"classes", @"students", @"observations", @"photos", nil];
    for (NSString *type in objectTypes) {
        NSURL *url = [[NSURL alloc] initWithString:[[self getUserURL] stringByAppendingFormat:@"%@/active", type]];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [self addWorkItem:[[BaseRESTDelegate alloc] initWithRequest:request]];
    }
}

- (void)resyncWithRemoteServer {
    //  TODO - prevent multiple items queued - better?
    if ([_workQueue count] > 0) {
        return;
    }
    [self updateFromRemoteServer];

    NSArray *objectTypes = [[NSArray alloc] initWithObjects:CATEGORYENTITY, CLASSLISTENTITY, STUDENTENTITY, OBSERVATIONENTITY, PHOTOENTITY, nil];
    for (NSString *type in objectTypes) {
        NSArray *dirtyEntities = [[EEYEOLocalDataStore instance] getDirtyEntities:type];
        for (EEYEOIdObject *entity in dirtyEntities) {
            [self saveEntityToRemote:entity];
        }
    }
    //  TODO - this actually requests same modified timestamp as previous call
    //  Works but hacky
    [self updateFromRemoteServer];
}

- (void)updateFromRemoteServer {
    NSURL *url = [[NSURL alloc] initWithString:[self lastModifiedURL]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [self addWorkItem:[[UpdatesFromServerRESTDelegate alloc] initWithRequest:request]];
}

- (void)saveEntityToRemote:(EEYEOIdObject *)object {
    if ([object isKindOfClass:[EEYEODeletedObject class]]) {
        return [self deleteEntityToRemote:(EEYEODeletedObject *) object];
    }
    if ([[object id] isEqualToString:@""]) {
        return [self createEntityToRemote:object];
    }
    return [self updateEntityToRemote:object];
}

- (void)updateEntityToRemote:(EEYEOIdObject *)updated {
    NSURLRequest *request = [self createWriteRequestToRemoteServer:updated method:@"PUT" urlString:[self getEntityURL:updated]];
    [self addWorkItem:[[BaseRESTDelegate alloc] initWithRequest:request]];
}

- (void)createEntityToRemote:(EEYEOIdObject *)created {
    NSURLRequest *request = [self createWriteRequestToRemoteServer:created method:@"POST" urlString:[self getUserURL]];
    [self addWorkItem:[[CreationRESTDelegate alloc] initWithRequest:request AndEntity:created]];
}

- (void)deleteEntityToRemote:(EEYEODeletedObject *)deleted {
    NSURL *url = [[NSURL alloc] initWithString:[self getEntityURL:deleted]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"DELETE"];

    [self addWorkItem:[[BaseRESTDelegate alloc] initWithRequest:request]];
}

- (NSURLRequest *)createWriteRequestToRemoteServer:(EEYEOIdObject *)entity method:(NSString *)method urlString:(NSString *)urlString {
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:method];

    NSMutableDictionary *dictionary = [self getDictionary:entity];
    [self writeDictionaryAsForm:request dictionary:dictionary forEntity:entity];
    return request;
}

- (void)writeDictionaryAsForm:(NSMutableURLRequest *)request dictionary:(NSMutableDictionary *)dictionary forEntity:(EEYEOIdObject *)entity {
    NSError *error;
    NSOutputStream *stream = [[NSOutputStream alloc] initToMemory];
    [stream open];
    [NSJSONSerialization writeJSONObject:dictionary toStream:stream options:NSJSONWritingPrettyPrinted error:&error];
    [stream close];
    NSData *streamData = [stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    NSString *form = [[NSString alloc] initWithFormat:@"appUserOwnedObject=%@", [[NSString alloc] initWithData:streamData encoding:NSASCIIStringEncoding]];

    //  TODO - hack to do with JSON parser requiring entity type being first field
    NSString *replacement = [[NSString alloc] initWithFormat:@"appUserOwnedObject={ \"entityType\": \"%@\",", [[EEYEORemoteDataStore iosToJavaEntityMap] valueForKey:[[entity class] description]]];
    form = [form stringByReplacingOccurrencesOfString:@"appUserOwnedObject={" withString:replacement];

    char const *bytes = [form UTF8String];
    [request setHTTPBody:[NSData dataWithBytes:bytes length:[form length]]];
}

- (NSMutableDictionary *)getDictionary:(EEYEOIdObject *)entity {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [entity writeToDictionary:dictionary];
    return dictionary;
}

@end