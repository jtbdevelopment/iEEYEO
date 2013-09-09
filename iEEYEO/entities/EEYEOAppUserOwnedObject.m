//
//  EEYEOAppUserOwnedObject.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "EEYEOObservation.h"
#import "EEYEOLocalDataStore.h"


@implementation EEYEOAppUserOwnedObject

@dynamic archived;
@dynamic appUser;
@dynamic photos;

- (BOOL)loadFromDictionary:(NSDictionary *)dictionary {
    EEYEOAppUser *user = [[EEYEOLocalDataStore instance] find:APPUSERENTITY withId:[[dictionary valueForKey:JSON_APPUSER] valueForKey:JSON_ID]];
    if (user) {
        [self setAppUser:user];
    } else {
        return NO;
    }
    [self setArchived:[[dictionary valueForKey:JSON_ARCHIVED] boolValue]];
    return [super loadFromDictionary:dictionary];
}

- (void)writeToDictionary:(NSMutableDictionary *)dictionary {
    [super writeToDictionary:dictionary];
    [dictionary setValue:[[NSNumber alloc] initWithBool:[self archived]] forKey:JSON_ARCHIVED];
    [self writeSubobject:[self appUser] ToDictionary:dictionary WithKey:JSON_APPUSER];
}

@end
