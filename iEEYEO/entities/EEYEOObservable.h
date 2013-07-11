//
//  EEYEOObservable.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EEYEOAppUserOwnedObject.h"

@class EEYEOObservation;

@interface EEYEOObservable : EEYEOAppUserOwnedObject

@property(nonatomic, retain) NSSet *observations;

@end

@interface EEYEOObservable (CoreDataGeneratedAccessors)

- (void)addObservationsObject:(EEYEOObservation *)value;

- (void)removeObservationsObject:(EEYEOObservation *)value;

- (void)addObservations:(NSSet *)values;

- (void)removeObservations:(NSSet *)values;

@end
