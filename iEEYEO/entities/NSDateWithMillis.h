//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>


@interface NSDateWithMillis : NSObject
@property(nonatomic, copy) NSDate *date;
@property(nonatomic) int32_t millis;

+ (id)dateFromJodaTime:(NSNumber *)jodaDateTimeInMilliseconds;

+ (id)dateWithTimeIntervalFromNow:(NSTimeInterval)secs;

- (id)initWithJodaTime:(NSNumber *)jodaDateTimeInMilliseconds;

- (id)initWithNSDate:(NSDate *)date1 AndMillis:(int32_t)millis1;

- (NSComparisonResult)compare:(NSDateWithMillis *)other;

- (NSNumber *)toJodaDateTime;

@end