//
//  EEYEOIdObject.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "EEYEOObservation.h"
#import "EEYEORemoteDataStore.h"
#import "NSDateWithMillis.h"


@implementation EEYEOIdObject

@dynamic id;
@dynamic modificationTimestamp;
@dynamic modificationTimestampMillis;
@dynamic dirty;

+ (NSDate *)fromJodaLocalDateTime:(NSArray *)jodaLocalDateTime {
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

+ (NSMutableArray *)toJodaLocalDateTime:(NSDate *)date {
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

- (NSNumber *)modificationTimestampToJoda {
    return [[self modificationTimestampToNSDateWithMillis] toJodaDateTime];
}

- (NSDateWithMillis *)modificationTimestampToNSDateWithMillis {
    NSDateWithMillis *date = [[NSDateWithMillis alloc] init];
    [date setDate:[NSDate dateWithTimeIntervalSince1970:[self modificationTimestamp]]];
    [date setMillis:[self modificationTimestampMillis]];
    return date;
}

- (NSString *)desc {
    return [self id];
}

- (BOOL)loadFromDictionary:(NSDictionary *)dictionary {
    [self setId:[dictionary valueForKey:JSON_ID]];
    [self setModificationTimestampFromJoda:[dictionary valueForKey:JSON_MODIFICATIONTS]];
    return YES;
}

- (void)writeToDictionary:(NSMutableDictionary *)dictionary {
    [dictionary setValue:[self id] forKey:JSON_ID];
    [dictionary setValue:[self modificationTimestampToJoda] forKey:JSON_MODIFICATIONTS];
    [dictionary setValue:[[EEYEORemoteDataStore iosToJavaEntityMap] valueForKey:[[self class] description]] forKey:JSON_ENTITY];
}

- (void)setModificationTimestampFromNSDateWithMillis:(NSDateWithMillis *)date {
    [self setModificationTimestamp:[[date date] timeIntervalSince1970]];
    [self setModificationTimestampMillis:[date millis]];
}

- (void)setModificationTimestampFromJoda:(NSNumber *)millis {
    [self setModificationTimestampFromNSDateWithMillis:[NSDateWithMillis dateFromJodaTime:millis]];
}

- (void)writeSubobject:(id)object ToArray:(NSMutableArray *)array {
    [array addObject:[self createSubDictionary:object]];
}

- (void)writeSubobject:(id)object ToDictionary:(NSMutableDictionary *)dictionary WithKey:(NSString *)key {
    [dictionary setValue:[self createSubDictionary:object] forKey:key];
}

- (NSMutableDictionary *)createSubDictionary:(id)object {
    NSMutableDictionary *subDictionary = [[NSMutableDictionary alloc] init];
    [subDictionary setValue:[[EEYEORemoteDataStore iosToJavaEntityMap] valueForKey:[[object class] description]] forKey:JSON_ENTITY];
    [subDictionary setValue:[object id] forKey:JSON_ID];
    return subDictionary;
}
@end
