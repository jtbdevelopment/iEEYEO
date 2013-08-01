//
//  EEYEOObservation.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "EEYEOObservation.h"
#import "EEYEOObservable.h"
#import "EEYEOLocalDataStore.h"
#import "EEYEOObservationCategory.h"


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

- (BOOL)loadFromDictionary:(NSDictionary *)dictionary {
    [self setComment:[dictionary valueForKey:JSON_COMMENT]];
    [self setSignificant:[[dictionary valueForKey:JSON_SIGNIFICANT] boolValue]];
    EEYEOObservable *observable = [[EEYEOLocalDataStore instance] find:OBSERVABLEENTITY withId:[[dictionary valueForKey:JSON_OBSERVATION_SUBJECT] valueForKey:JSON_ID]];
    if (observable) {
        [self setObservable:observable];
    } else {
        return NO;
    }
    for (NSDictionary *category in [dictionary valueForKey:JSON_CATEGORIES]) {
        EEYEOObservationCategory *value = [[EEYEOLocalDataStore instance] find:CATEGORYENTITY withId:[category valueForKey:JSON_ID]];
        if (value) {
            [self addCategoriesObject:value];
        } else {
            return NO;
        }
    }
    [self setObservationTimestampFromNSDate:[self fromJodaLocalDateTime:[dictionary valueForKey:JSON_OBSERVATIONTIMESTAMP]]];
    return [super loadFromDictionary:dictionary];
}

- (void)writeToDictionary:(NSMutableDictionary *)dictionary {
    [super writeToDictionary:dictionary];
    [dictionary setValue:[self comment] forKey:JSON_COMMENT];
    [dictionary setValue:[[NSNumber alloc] initWithBool:[self significant]] forKey:JSON_SIGNIFICANT];
    [self writeSubobject:[self observable] ToDictionary:dictionary WithKey:JSON_OBSERVATION_SUBJECT];
    NSMutableArray *categories = [[NSMutableArray alloc] init];
    for (EEYEOObservationCategory *category in [self categories]) {
        [self writeSubobject:category ToArray:categories];
    }
    [dictionary setValue:categories forKey:JSON_CATEGORIES];
    [dictionary setValue:[self toJodaLocalDateTime:[self observationTimestampToNSDate]] forKey:JSON_OBSERVATIONTIMESTAMP];
}

- (NSDate *)observationTimestampToNSDate {
    return [NSDate dateWithTimeIntervalSince1970:[self observationTimestamp]];
}

- (void)setObservationTimestampFromNSDate:(NSDate *)date {
    [self setObservationTimestamp:[date timeIntervalSince1970]];
}

- (NSString *)desc {
    NSMutableString *s = [[NSMutableString alloc] initWithString:[self.observable desc]];
    [s appendString:@" @ "];
    [s appendString:[_dateFormatter stringFromDate:[self observationTimestampToNSDate]]];
    return s;
}


@end
