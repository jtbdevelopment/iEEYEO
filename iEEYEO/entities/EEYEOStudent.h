//
//  EEYEOStudent.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EEYEOObservable.h"

@class EEYEOClassList;

@interface EEYEOStudent : EEYEOObservable

@property(nonatomic, retain) NSString *firstName;
@property(nonatomic, retain) NSString *lastName;
@property(nonatomic, retain) NSSet *classLists;
@end

@interface EEYEOStudent (CoreDataGeneratedAccessors)

- (void)addClassListsObject:(EEYEOClassList *)value;

- (void)removeClassListsObject:(EEYEOClassList *)value;

- (void)addClassLists:(NSSet *)values;

- (void)removeClassLists:(NSSet *)values;

@end
