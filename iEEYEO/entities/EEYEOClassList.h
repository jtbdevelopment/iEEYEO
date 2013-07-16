//
//  EEYEOClassList.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EEYEOObservable.h"

@class EEYEOStudent;

@interface EEYEOClassList : EEYEOObservable

@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSSet *students;
@end

@interface EEYEOClassList (CoreDataGeneratedAccessors)

- (void)addStudentsObject:(EEYEOStudent *)value;

- (void)removeStudentsObject:(EEYEOStudent *)value;

- (void)addStudents:(NSSet *)values;

- (void)removeStudents:(NSSet *)values;

@end
