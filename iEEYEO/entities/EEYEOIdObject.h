//
//  EEYEOIdObject.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EEYEOIdObject : NSManagedObject

@property(nonatomic, retain) NSString *id;
@property(nonatomic) NSTimeInterval modificationTimestamp;
@property(nonatomic) BOOL dirty;

+ (NSDate *)fromJodaDateTime:(long long int)jodaDateTimeInMilliseconds;

+ (long long int)toJodaDateTime:(NSDate *)dateTime;

- (long long)modificationTimestampToJoda;

- (NSDate *)modificationTimestampToNSDate;

- (void)setModificationTimestampFromNSDate:(NSDate *)date;

- (void)setModificationTimestampFromJoda:(long long)millis;

- (NSString *)desc;


@end
