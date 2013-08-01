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

//  TODO - move to base?
- (NSDate *)fromJodaLocalDateTime:(NSArray *)jodaLocalDateTime {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    [components setCalendar:cal];
    [components setYear:[[jodaLocalDateTime objectAtIndex:0] integerValue]];
    [components setMonth:[[jodaLocalDateTime objectAtIndex:1] integerValue]];
    [components setDay:[[jodaLocalDateTime objectAtIndex:2] integerValue]];
    [components setHour:[[jodaLocalDateTime objectAtIndex:3] integerValue]];
    [components setMinute:[[jodaLocalDateTime objectAtIndex:4] integerValue]];
    [components setSecond:[[jodaLocalDateTime objectAtIndex:5] integerValue]];
    NSDate *date = [cal dateFromComponents:components];
    return date;
}

//  TODO - move to base?
- (NSMutableArray *)toJodaLocalDateTime:(NSDate *)date {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:LOCAL_DATE_TIME_FLAGS fromDate:date];
    NSMutableArray *ts = [[NSMutableArray alloc] init];
    [ts addObject:[[NSNumber alloc] initWithInt:[comps year]]];
    [ts addObject:[[NSNumber alloc] initWithInt:[comps month]]];
    [ts addObject:[[NSNumber alloc] initWithInt:[comps day]]];
    [ts addObject:[[NSNumber alloc] initWithInt:[comps hour]]];
    [ts addObject:[[NSNumber alloc] initWithInt:[comps minute]]];
    [ts addObject:[[NSNumber alloc] initWithInt:[comps second]]];
    [ts addObject:[[NSNumber alloc] initWithInt:0]];
    return ts;
}
@end
