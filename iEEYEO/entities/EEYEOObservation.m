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


- (NSDate *)observationTSAsNSDate {
    return [EEYEOIdObject fromJodaDateTime:[self observationTimestamp]];
}

- (void)setObservationTSAsNSDate:(NSDate *)observationTS {
    [self setObservationTimestamp:[EEYEOIdObject toJodaDateTime:observationTS]];
}

- (NSString *)desc {
    NSMutableString *s = [[NSMutableString alloc] initWithString:[self.observable desc]];
    [s appendString:@" @ "];
    [s appendString:[_dateFormatter stringFromDate:[self observationTSAsNSDate]]];
    return s;
}

@end
