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

@interface EEYEOObservation : EEYEOAppUserOwnedObject

@property(nonatomic, retain) NSString *comment;
@property(nonatomic) int64_t observationTimestamp;
@property(nonatomic) BOOL significant;
@property(nonatomic, retain) NSSet *categories;
@property(nonatomic, retain) EEYEOObservable *observable;
@end

@interface EEYEOObservation (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(EEYEOObservationCategory *)value;

- (void)removeCategoriesObject:(EEYEOObservationCategory *)value;

- (void)addCategories:(NSSet *)values;

- (void)removeCategories:(NSSet *)values;

@end
