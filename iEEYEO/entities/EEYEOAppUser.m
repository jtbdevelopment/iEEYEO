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
@dynamic lastLogout;
@dynamic lastName;
@dynamic ownedObjects;

- (void)loadFromDictionary:(NSDictionary *)dictionary {
    [super loadFromDictionary:dictionary];
    [self setActivated:[[dictionary valueForKey:JSON_ACTIVATED] boolValue]];
    [self setAdmin:[[dictionary valueForKey:JSON_ADMIN] boolValue]];
    [self setActive:[[dictionary valueForKey:JSON_ACTIVE] boolValue]];
    [self setEmailAddress:[dictionary valueForKey:JSON_EMAIL_ADDRESS]];
    [self setFirstName:[dictionary valueForKey:JSON_FIRST_NAME]];
    [self setLastName:[dictionary valueForKey:JSON_LAST_NAME]];
    [self setLastLogoutFromJoda:[dictionary valueForKey:JSON_LASTLOGOUT]];
}

- (void)writeToDictionary:(NSMutableDictionary *)dictionary {
    [super writeToDictionary:dictionary];
    [dictionary setValue:[[NSNumber alloc] initWithBool:[self activated]] forKey:JSON_ACTIVATED];
    [dictionary setValue:[[NSNumber alloc] initWithBool:[self active]] forKey:JSON_ACTIVE];
    [dictionary setValue:[[NSNumber alloc] initWithBool:[self admin]] forKey:JSON_ADMIN];
    [dictionary setValue:[self emailAddress] forKey:JSON_EMAIL_ADDRESS];
    [dictionary setValue:[self firstName] forKey:JSON_FIRST_NAME];
    [dictionary setValue:[self lastName] forKey:JSON_LAST_NAME];
    [dictionary setValue:[self lastLogoutToJoda] forKey:JSON_LASTLOGOUT];
}

- (NSNumber *)lastLogoutToJoda {
    return [EEYEOIdObject toJodaDateTime:[self lastLogoutToNSDate]];
}

- (NSDate *)lastLogoutToNSDate {
    return [NSDate dateWithTimeIntervalSince1970:[self lastLogout]];
}

- (void)setLastLogoutFromNSDate:(NSDate *)date {
    [self setLastLogout:[date timeIntervalSince1970]];
}

- (void)setLastLogoutFromJoda:(NSNumber *)millis {
    [self setLastLogoutFromNSDate:[EEYEOIdObject fromJodaDateTime:millis]];
}

@end
