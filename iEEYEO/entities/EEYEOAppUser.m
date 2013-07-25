//
//  EEYEOAppUser.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "EEYEOAppUser.h"


@implementation EEYEOAppUser

@dynamic activated;
@dynamic active;
@dynamic admin;
@dynamic emailAddress;
@dynamic firstName;
@dynamic lastName;
@dynamic ownedObjects;

- (BOOL)loadFromDictionary:(NSDictionary *)dictionary {
    [self setActivated:[[dictionary valueForKey:JSON_ACTIVATED] boolValue]];
    [self setAdmin:[[dictionary valueForKey:JSON_ADMIN] boolValue]];
    [self setActive:[[dictionary valueForKey:JSON_ACTIVE] boolValue]];
    [self setEmailAddress:[dictionary valueForKey:JSON_EMAIL_ADDRESS]];
    [self setFirstName:[dictionary valueForKey:JSON_FIRST_NAME]];
    [self setLastName:[dictionary valueForKey:JSON_LAST_NAME]];
    return [super loadFromDictionary:dictionary];
}

- (void)writeToDictionary:(NSMutableDictionary *)dictionary {
    [super writeToDictionary:dictionary];
    [dictionary setValue:[[NSNumber alloc] initWithBool:[self activated]] forKey:JSON_ACTIVATED];
    [dictionary setValue:[[NSNumber alloc] initWithBool:[self active]] forKey:JSON_ACTIVE];
    [dictionary setValue:[[NSNumber alloc] initWithBool:[self admin]] forKey:JSON_ADMIN];
    [dictionary setValue:[self emailAddress] forKey:JSON_EMAIL_ADDRESS];
    [dictionary setValue:[self firstName] forKey:JSON_FIRST_NAME];
    [dictionary setValue:[self lastName] forKey:JSON_LAST_NAME];
}

@end
