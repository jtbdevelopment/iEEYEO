//
//  EEYEOIdObject.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "EEYEOIdObject.h"


@implementation EEYEOIdObject

@dynamic id;
@dynamic modificationTimestamp;

- (NSDate *)modificationTSAsNSDate {
    return [EEYEOIdObject fromJodaDateTime:[self modificationTimestamp]];
}

- (void)setModificationTSAsNSDate:(NSDate *)dateTime {
    [self setModificationTimestamp:[EEYEOIdObject toJodaDateTime:dateTime]];
}

+ (NSDate *)fromJodaDateTime:(long long int)jodaDateTimeInMilliseconds {
    return [NSDate dateWithTimeIntervalSince1970:((int) (jodaDateTimeInMilliseconds / 1000))];
}

+ (long long int)toJodaDateTime:(NSDate *)dateTime {
    return (long long) ([dateTime timeIntervalSince1970] * 1000);
}

@end
