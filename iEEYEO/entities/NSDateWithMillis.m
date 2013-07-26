//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "NSDateWithMillis.h"


@implementation NSDateWithMillis {

}

@synthesize millis;
@synthesize date;

+ (id)dateWithTimeIntervalFromNow:(NSTimeInterval)secs {
    return [[NSDateWithMillis alloc] initWithNSDate:[NSDate dateWithTimeIntervalSinceNow:secs] AndMillis:0];
}

+ (id)dateFromJodaTime:(NSNumber *)jodaDateTimeInMilliseconds {
    return [[NSDateWithMillis alloc] initWithJodaTime:jodaDateTimeInMilliseconds];
}

- (id)init {
    self = [super init];
    if (self) {
        date = [NSDate dateWithTimeIntervalSince1970:(40 * 365 * 24 * 60 * 60)];
        millis = 0;
    }

    return self;
}

- (id)initWithJodaTime:(NSNumber *)jodaDateTimeInMilliseconds {
    self = [super init];
    if (self) {
        unsigned long long int m = [jodaDateTimeInMilliseconds unsignedLongLongValue];
        double secs = ((double) m) / 1000;
        int32_t mRemain = m - ((unsigned long long int) ((int) secs * 1000));
        date = [NSDate dateWithTimeIntervalSince1970:secs];
        millis = mRemain;
    }
    return self;
}

- (id)initWithNSDate:(NSDate *)withDate AndMillis:(int32_t)withMillis {
    self = [super init];
    if (self) {
        date = withDate;
        millis = withMillis;
    }
    return self;
}

- (NSNumber *)toJodaDateTime {
    return [[NSNumber alloc] initWithUnsignedLongLong:(((unsigned long long) ([[self date] timeIntervalSince1970] * 1000)) + [self millis])];
}

- (NSComparisonResult)compare:(NSDateWithMillis *)other {
    NSComparisonResult dateResult;
    //  TODO - why weird results here?
    dateResult = [[other date] compare:[self date]];
    dateResult = [[self date] compare:[other date]];
    if (dateResult != NSOrderedSame) {
        return dateResult;
    }
    if (millis > [other millis]) {
        return NSOrderedDescending;
    }
    if (millis < [other millis]) {
        return NSOrderedAscending;
    }
    return NSOrderedSame;
}

@end