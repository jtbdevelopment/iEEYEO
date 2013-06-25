//
//  EEYEOObservation.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "EEYEOObservation.h"


@implementation EEYEOObservation

@dynamic comment;
@dynamic observationTimestamp;
@dynamic significant;
@dynamic categories;
@dynamic observable;

- (NSDate *)observationTSAsNSDate {
    return [EEYEOIdObject fromJodaDateTime:[self observationTimestamp]];
}

- (void)setObservationTSAsNSDate:(NSDate *)observationTS {
    [self setObservationTimestamp:[EEYEOIdObject toJodaDateTime:observationTS]];
}


@end
