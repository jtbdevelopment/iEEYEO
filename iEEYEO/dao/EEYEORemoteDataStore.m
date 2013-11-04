//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "EEYEORemoteDataStore.h"
#import "EEYEOObservationCategory.h"
#import "EEYEOLocalDataStore.h"
#import "NSDateWithMillis.h"
#import "EEYEOAppUser.h"
#import "Reachability.h"
#import "EEYEORemoteQueue.h"
#import "ReadUsersFromRemoteCoordinator.h"
#import "ReadCategoryFromRemoteCoordinator.h"
#import "ReadUpdatesFromRemoteCoordinator.h"
#import "WriteToRemoteCoordinator.h"


@implementation EEYEORemoteDataStore {
@private
    EEYEORemoteQueue *remoteQueue;
    NSDateFormatter *_dateFormatter;
    NSNumberFormatter *_numberFormatter;

    NSTimer *_timer;

    Reachability __weak *_reachability;
}


@synthesize reachability = _reachability;

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
        [map setValue:PHOTOENTITY forKey:JAVA_PHOTO];
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
        remoteQueue = [EEYEORemoteQueue instance];

        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];

        _numberFormatter = [[NSNumberFormatter alloc] init];
        //  TODO??
        //[_dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:@"GMT"]];

        _timer = nil;

        _reachability = [Reachability reachabilityWithHostname:@"www.e-eye-o.com"];
        [_reachability setReachableOnWWAN:NO];
#if TARGET_IPHONE_SIMULATOR
        [remoteQueue setNetworkAvailable:YES];
#else
        [remoteQueue setNetworkAvailable:[[Reachability reachabilityForLocalWiFi] isReachable]];
#endif
        _reachability.reachableBlock = ^(Reachability *reach) {
            [remoteQueue setNetworkAvailable:YES];
            [remoteQueue processNextRequest];
        };
        _reachability.unreachableBlock = ^(Reachability *reach) {
            [remoteQueue setNetworkAvailable:NO];
        };
        [_reachability startNotifier];
    };

    if ([[self lastUpdateFromServer] count] == 0) {
        [self setLastUpdateFromServerWithNSDateWithMillis:[[NSDateWithMillis alloc] init]];
    }
    if ([[self lastServerResync] count] == 0) {
        [self setLastServerResyncWithNSDateWithMillis:[[NSDateWithMillis alloc] init]];
    }
    if ([self refreshFrequency] == 0) {
        [self setRefreshFrequency:4];
    }

    return self;
}

- (void)haltRemoteSyncs {
    @synchronized (self) {
        [self stopTimer];
        [remoteQueue resetQueue];
    }
}

- (void)startRemoteSyncs {
    @synchronized (self) {
        [self startTimer];
    }
}

- (void)stopTimer {
    @synchronized (self) {
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
    }
}

- (void)startTimer {
    @synchronized (self) {
        if (_timer) {
            return;
        }
        _timer = [NSTimer scheduledTimerWithTimeInterval:([self refreshFrequency] * 3600) target:self selector:@selector(remoteSyncTimer:) userInfo:nil repeats:YES];
    }
}

- (void)resetTimer {
    [self stopTimer];
    [self startTimer];
}

- (void)remoteSyncTimer:(NSTimer *)timer {
    [self resyncWithRemoteServer];
}


- (NSString *)getCurrentUserID {
    EEYEOAppUser *appUser = [[EEYEOLocalDataStore instance] appUser];
    if (appUser) {
        return [appUser id];
    }
    return @"NOTFOUND";
}

- (void)setLastServerResyncWithNSDateWithMillis:(NSDateWithMillis *)value {
    @synchronized (self) {
        NSDateWithMillis *currentValue = [self lastServerResyncAsNSDateWithMillis];
        if ([currentValue compare:value] != NSOrderedAscending) {
            return;
        }
        NSMutableArray *strings = [[NSMutableArray alloc] init];
        [strings addObject:[_dateFormatter stringFromDate:[value date]]];
        [strings addObject:[_numberFormatter stringFromNumber:[[NSNumber alloc] initWithInt:[value millis]]]];
        [self setLastServerResync:strings];
    }
}

- (void)setLastServerResync:(NSArray *)values {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[values objectAtIndex:0] forKey:LAST_RESYNC_KEY];
    [defaults setObject:[values objectAtIndex:1] forKey:LAST_RESYNCMILLIS_KEY];
    [defaults synchronize];
}

- (NSString *)lastServerResyncAsString {
    NSDateWithMillis *dateWithMillis = [self lastServerResyncAsNSDateWithMillis];
    NSString *string = [_dateFormatter stringFromDate:[dateWithMillis date]];
    return [string stringByAppendingFormat:@".%03d", [dateWithMillis millis]];
}

- (NSDateWithMillis *)lastServerResyncAsNSDateWithMillis {
    NSArray *strings = [self lastServerResync];
    if ([strings count] > 0) {
        return [[NSDateWithMillis alloc] initWithNSDate:[_dateFormatter dateFromString:[strings objectAtIndex:0]] AndMillis:[[_numberFormatter numberFromString:[strings objectAtIndex:1]] intValue]];
    } else {
        return [[NSDateWithMillis alloc] init];
    }
}

- (NSArray *)lastServerResync {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:LAST_RESYNC_KEY];
    if (value) {
        [array addObject:value];
        [array addObject:[[NSUserDefaults standardUserDefaults] stringForKey:LAST_RESYNCMILLIS_KEY]];
    }
    return array;
}

- (void)setLastUpdateFromServerWithNSDateWithMillis:(NSDateWithMillis *)value {
    @synchronized (self) {
        NSDateWithMillis *currentValue = [self lastUpdateFromServerAsNSDateWithMillis];
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

- (NSString *)lastUpdateFromServerAsString {
    NSDateWithMillis *dateWithMillis = [self lastUpdateFromServerAsNSDateWithMillis];
    NSString *string = [_dateFormatter stringFromDate:[dateWithMillis date]];
    return [string stringByAppendingFormat:@".%03d", [dateWithMillis millis]];
}

- (NSDateWithMillis *)lastUpdateFromServerAsNSDateWithMillis {
    NSArray *strings = [self lastUpdateFromServer];
    if ([strings count] > 0) {
        return [[NSDateWithMillis alloc] initWithNSDate:[_dateFormatter dateFromString:[strings objectAtIndex:0]] AndMillis:[[_numberFormatter numberFromString:[strings objectAtIndex:1]] intValue]];
    } else {
        return [[NSDateWithMillis alloc] init];
    }
}

- (NSArray *)lastUpdateFromServer {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:LAST_MODTS_KEY];
    if (value) {
        [array addObject:value];
        [array addObject:[[NSUserDefaults standardUserDefaults] stringForKey:LAST_MODTSMILLIS_KEY]];
    }
    return array;
}

- (void)setRefreshFrequency:(int)frequency {
    NSString *value = [NSString stringWithFormat:@"%d", frequency];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:REFRESH_FREQUENCY_KEY];
    [defaults synchronize];
    [self resetTimer];
}

- (int)refreshFrequency {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [defaults stringForKey:REFRESH_FREQUENCY_KEY];
    if (value) {
        return [[_numberFormatter numberFromString:value] intValue];
    } else {
        return 0;
    }
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self instance];
}

- (void)initializeFromRemoteServer {
    [remoteQueue addRequest:[[ReadUsersFromRemoteCoordinator alloc] init]];

    NSArray *objectTypes = [[NSArray alloc] initWithObjects:@"categories", @"classes", @"students", @"observations", @"photos", nil];
    for (NSString *type in objectTypes) {
        [remoteQueue addRequest:[[ReadCategoryFromRemoteCoordinator alloc] initWithCategory:type]];
    }
}

- (void)resyncWithRemoteServer {
    [remoteQueue addRequest:[[ReadUpdatesFromRemoteCoordinator alloc] init]];

    NSArray *objectTypes = [[NSArray alloc] initWithObjects:CATEGORYENTITY, CLASSLISTENTITY, STUDENTENTITY, OBSERVATIONENTITY, PHOTOENTITY, DELETEDENTITY, nil];
    for (NSString *type in objectTypes) {
        [remoteQueue addRequest:[[WriteToRemoteCoordinator alloc] initWithCategory:type]];
    }

    [remoteQueue addRequest:[[ReadUpdatesFromRemoteCoordinator alloc] init]];
}

@end