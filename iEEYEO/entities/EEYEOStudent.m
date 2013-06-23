//
//  EEYEOStudent.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "EEYEOStudent.h"


@implementation EEYEOStudent

@dynamic firstName;
@dynamic lastName;
@dynamic classLists;

- (NSString *)description {
    NSMutableString *firstLast = [[NSMutableString alloc] initWithString:[self firstName]];
    if (self.lastName) {
        [firstLast appendString:@" "];
        [firstLast appendString:[self lastName]];
    }
    return firstLast;
}

@end
