//
//  EEYEOIdObject.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "EEYEOIdObject.h"
#import "EEYEORemoteDataStore.h"


@implementation EEYEOIdObject

@dynamic id;
@dynamic modificationTimestamp;
@dynamic dirty;

- (NSNumber *)modificationTimestampToJoda {
    return [EEYEOIdObject toJodaDateTime:[self modificationTimestampToNSDate]];
}

- (NSDate *)modificationTimestampToNSDate {
    return [NSDate dateWithTimeIntervalSince1970:[self modificationTimestamp]];
}

- (NSString *)desc {
    return [self id];
}

- (void)loadFromDictionary:(NSDictionary *)dictionary {
    [self setId:[dictionary valueForKey:JSON_ID]];
    [self setModificationTimestampFromJoda:[dictionary valueForKey:JSON_MODIFICATIONTS]];
}

- (void)writeToDictionary:(NSMutableDictionary *)dictionary {
    [dictionary setValue:[self id] forKey:JSON_ID];
    [dictionary setValue:[self modificationTimestampToJoda] forKey:JSON_MODIFICATIONTS];
}

- (void)setModificationTimestampFromNSDate:(NSDate *)date {
    [self setModificationTimestamp:[date timeIntervalSince1970]];
}

- (void)setModificationTimestampFromJoda:(NSNumber *)millis {
    [self setModificationTimestampFromNSDate:[EEYEOIdObject fromJodaDateTime:millis]];
}

+ (NSDate *)fromJodaDateTime:(NSNumber *)jodaDateTimeInMilliseconds {
    return [NSDate dateWithTimeIntervalSince1970:(((double) [jodaDateTimeInMilliseconds longLongValue]) / 1000)];
}

+ (NSNumber *)toJodaDateTime:(NSDate *)dateTime {
    return [[NSNumber alloc] initWithUnsignedLongLong:((long long) ([dateTime timeIntervalSince1970] * 1000))];
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
