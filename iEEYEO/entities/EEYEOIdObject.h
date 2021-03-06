//
//  EEYEOIdObject.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSDateWithMillis;

static NSString *const JSON_ID = @"id";

static NSString *const JSON_ENTITY = @"entityType";

static NSString *const JSON_MODIFICATIONTS = @"modificationTimestamp";

static NSString *const JSON_DESCRIPTION = @"description";

static NSString *const JSON_SHORTNAME = @"shortName";

static NSString *const JSON_FIRST_NAME = @"firstName";

static NSString *const JSON_LAST_NAME = @"lastName";

@interface EEYEOIdObject : NSManagedObject

@property(nonatomic, retain) NSString *id;
@property(nonatomic) NSTimeInterval modificationTimestamp;
@property(nonatomic) int32_t modificationTimestampMillis;
@property(nonatomic) BOOL dirty;

+ (NSDate *)fromJodaLocalDateTime:(NSArray *)jodaLocalDateTime;

+ (NSMutableArray *)toJodaLocalDateTime:(NSDate *)date;

- (void)writeSubobject:(id)object ToArray:(NSMutableArray *)array;

- (void)writeSubobject:(id)object ToDictionary:(NSMutableDictionary *)dictionary WithKey:(NSString *)key;

- (NSNumber *)modificationTimestampToJoda;

- (NSDateWithMillis *)modificationTimestampToNSDateWithMillis;

- (void)setModificationTimestampFromNSDateWithMillis:(NSDateWithMillis *)date;

- (void)setModificationTimestampFromJoda:(NSNumber *)millis;

- (NSString *)desc;

- (BOOL)loadFromDictionary:(NSDictionary *)dictionary;

- (void)writeToDictionary:(NSMutableDictionary *)dictionary;
@end
