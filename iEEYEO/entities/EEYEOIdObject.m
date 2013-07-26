//
//  EEYEOIdObject.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "EEYEOIdObject.h"
#import "EEYEORemoteDataStore.h"
#import "NSDateWithMillis.h"


@implementation EEYEOIdObject

@dynamic id;
@dynamic modificationTimestamp;
@dynamic modificationTimestampMillis;
@dynamic dirty;

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
