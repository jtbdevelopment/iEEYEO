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

- (void)loadFromDictionary:(NSDictionary *)dictionary {
    [super loadFromDictionary:dictionary];
    [self setComment:[dictionary valueForKey:JSON_COMMENT]];
    [self setSignificant:[[dictionary valueForKey:JSON_SIGNIFICANT] boolValue]];
    //  TODO - error if not found
    [self setObservable:[[EEYEOLocalDataStore instance] find:OBSERVABLEENTITY withId:[[dictionary valueForKey:JSON_OBSERVATION_SUBJECT] valueForKey:JSON_ID]]];
    for (NSDictionary *category in [dictionary valueForKey:JSON_CATEGORIES]) {
        //  TODO - error if not found
        EEYEOObservationCategory *value = [[EEYEOLocalDataStore instance] find:CATEGORYENTITY withId:[category valueForKey:JSON_ID]];
        if (value) {
            [self addCategoriesObject:value];
        }
    }
    NSArray *jodaLocalDateTime = [dictionary valueForKey:JSON_OBSERVATIONTIMESTAMP];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    [components setCalendar:cal];
    [components setYear:[[jodaLocalDateTime objectAtIndex:0] integerValue]];
    [components setMonth:[[jodaLocalDateTime objectAtIndex:1] integerValue]];
    [components setDay:[[jodaLocalDateTime objectAtIndex:2] integerValue]];
    [components setHour:[[jodaLocalDateTime objectAtIndex:3] integerValue]];
    [components setMinute:[[jodaLocalDateTime objectAtIndex:4] integerValue]];
    [components setSecond:[[jodaLocalDateTime objectAtIndex:5] integerValue]];
    NSDate *date = [cal dateFromComponents:components];
    [self setObservationTimestamp:[date timeIntervalSince1970]];
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
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:LOCAL_DATE_TIME_FLAGS fromDate:[self observationTimestampToNSDate]];
    NSMutableArray *ts = [[NSMutableArray alloc] init];
    [ts addObject:[[NSNumber alloc] initWithInt:[comps year]]];
    [ts addObject:[[NSNumber alloc] initWithInt:[comps month]]];
    [ts addObject:[[NSNumber alloc] initWithInt:[comps day]]];
    [ts addObject:[[NSNumber alloc] initWithInt:[comps hour]]];
    [ts addObject:[[NSNumber alloc] initWithInt:[comps minute]]];
    [ts addObject:[[NSNumber alloc] initWithInt:[comps second]]];
    [ts addObject:[[NSNumber alloc] initWithInt:0]];
    [dictionary setValue:ts forKey:JSON_OBSERVATIONTIMESTAMP];
}

- (NSNumber *)observationTimestampToJoda {
    return [EEYEOIdObject toJodaDateTime:[self observationTimestampToNSDate]];
}

- (NSDate *)observationTimestampToNSDate {
    return [NSDate dateWithTimeIntervalSince1970:[self observationTimestamp]];
}

- (void)setObservationTimestampFromNSDate:(NSDate *)date {
    [self setObservationTimestamp:[date timeIntervalSince1970]];
}

- (void)setObservationTimestampFromJoda:(NSNumber *)millis {
    [self setObservationTimestampFromNSDate:[EEYEOIdObject fromJodaDateTime:millis]];
}

- (NSString *)desc {
    NSMutableString *s = [[NSMutableString alloc] initWithString:[self.observable desc]];
    [s appendString:@" @ "];
    [s appendString:[_dateFormatter stringFromDate:[self observationTimestampToNSDate]]];
    return s;
}


@end
