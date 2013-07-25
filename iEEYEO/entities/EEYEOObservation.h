//
//  EEYEOObservation.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EEYEOAppUserOwnedObject.h"

@class EEYEOObservable, EEYEOObservationCategory;

static NSString *const JSON_COMMENT = @"comment";

static NSString *const JSON_SIGNIFICANT = @"significant";

static NSString *const JSON_OBSERVATION_SUBJECT = @"observationSubject";

static NSString *const JSON_CATEGORIES = @"categories";

static NSString *const JSON_OBSERVATIONTIMESTAMP = @"observationTimestamp";

static const enum NSCalendarUnit LOCAL_DATE_TIME_FLAGS = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;

@interface EEYEOObservation : EEYEOAppUserOwnedObject

@property(nonatomic, retain) NSString *comment;
@property(nonatomic) NSTimeInterval observationTimestamp;
@property(nonatomic) BOOL significant;
@property(nonatomic, retain) NSSet *categories;
@property(nonatomic, retain) EEYEOObservable *observable;

- (NSDate *)observationTimestampToNSDate;

- (void)setObservationTimestampFromNSDate:(NSDate *)date;

- (NSString *)desc;

@end

@interface EEYEOObservation (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(EEYEOObservationCategory *)value;

- (void)removeCategoriesObject:(EEYEOObservationCategory *)value;

- (void)addCategories:(NSSet *)values;

- (void)removeCategories:(NSSet *)values;

@end
