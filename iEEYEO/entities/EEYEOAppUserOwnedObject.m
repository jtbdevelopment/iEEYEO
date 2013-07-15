//
//  EEYEOAppUserOwnedObject.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "EEYEOAppUserOwnedObject.h"
#import "EEYEOLocalDataStore.h"


@implementation EEYEOAppUserOwnedObject

@dynamic archived;
@dynamic appUser;

- (void)loadFromDictionary:(NSDictionary *)dictionary {
    [super loadFromDictionary:dictionary];
    //  TODO - error if not found
    [self setAppUser:[[EEYEOLocalDataStore instance] find:APPUSERENTITY withId:[[dictionary valueForKey:JSON_APPUSER] valueForKey:JSON_ID]]];
    [self setArchived:[[dictionary valueForKey:JSON_ARCHIVED] boolValue]];
}

- (void)writeToDictionary:(NSMutableDictionary *)dictionary {
    [super writeToDictionary:dictionary];
    [dictionary setValue:[[NSNumber alloc] initWithBool:[self archived]] forKey:JSON_ARCHIVED];
    [self writeSubobject:[self appUser] ToDictionary:dictionary WithKey:JSON_APPUSER];
}

@end
