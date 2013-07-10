//
//  EEYEOObservation.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "EEYEOObservation.h"
#import "EEYEOObservable.h"


@implementation EEYEOObservation {
@private
    NSDateFormatter *_dateFormatter;
}

@dynamic comment;
@dynamic observationTimestamp;
@dynamic significant;
@dynamic categories;
@dynamic observable;

- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self) {
        //  TODO - central
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }

    return self;
}

- (long long)observationTimestampToJoda {
    return [EEYEOIdObject toJodaDateTime:[self observationTimestampToNSDate]];
}

- (NSDate *)observationTimestampToNSDate {
    return [NSDate dateWithTimeIntervalSince1970:[self observationTimestamp]];
}

- (void)setObservationTimestampFromNSDate:(NSDate *)date {
    [self setObservationTimestamp:[date timeIntervalSince1970]];
}

- (void)setObservationTimestampFromJoda:(long long)millis {
    [self setObservationTimestampFromNSDate:[EEYEOIdObject fromJodaDateTime:millis]];
}

- (NSString *)desc {
    NSMutableString *s = [[NSMutableString alloc] initWithString:[self.observable desc]];
    [s appendString:@" @ "];
    [s appendString:[_dateFormatter stringFromDate:[self observationTimestampToNSDate]]];
    return s;
}

@end
