//
//  EEYEOObservationCategory.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EEYEOAppUserOwnedObject.h"

@class EEYEOObservation;

@interface EEYEOObservationCategory : EEYEOAppUserOwnedObject

@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *shortName;
@property(nonatomic, retain) NSSet *observations;
@end

@interface EEYEOObservationCategory (CoreDataGeneratedAccessors)

- (void)addObservationsObject:(EEYEOObservation *)value;

- (void)removeObservationsObject:(EEYEOObservation *)value;

- (void)addObservations:(NSSet *)values;

- (void)removeObservations:(NSSet *)values;

@end
