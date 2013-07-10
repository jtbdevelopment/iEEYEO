//
//  EEYEOIdObject.m
//  iEEYEO
//
//  Created by Joseph Buscemi on 7/10/13.
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "EEYEOIdObject.h"


@implementation EEYEOIdObject

@dynamic id;
@dynamic modificationTimestamp;
@dynamic dirty;

- (long long)modificationTimestampToJoda {
    return [EEYEOIdObject toJodaDateTime:[self modificationTimestampToNSDate]];
}

- (NSDate *)modificationTimestampToNSDate {
    return [NSDate dateWithTimeIntervalSince1970:[self modificationTimestamp]];
}

- (NSString *)desc {
    return [self id];
}

- (void)setModificationTimestampFromNSDate:(NSDate *)date {
    [self setModificationTimestamp:[date timeIntervalSince1970]];
}

- (void)setModificationTimestampFromJoda:(long long)millis {
    [self setModificationTimestampFromNSDate:[EEYEOIdObject fromJodaDateTime:millis]];
}

+ (NSDate *)fromJodaDateTime:(long long int)jodaDateTimeInMilliseconds {
    return [NSDate dateWithTimeIntervalSince1970:((int) (jodaDateTimeInMilliseconds / 1000))];
}

+ (long long int)toJodaDateTime:(NSDate *)dateTime {
    return (long long) ([dateTime timeIntervalSince1970] * 1000);
}


@end
