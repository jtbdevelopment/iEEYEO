//
//  EEYEOObservationCategory.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "EEYEOObservationCategory.h"


@implementation EEYEOObservationCategory

@dynamic name;
@dynamic shortName;
@dynamic observations;

- (void)loadFromDictionary:(NSDictionary *)dictionary {
    [super loadFromDictionary:dictionary];
    [self setName:[dictionary valueForKey:@"description"]];
    [self setShortName:[dictionary valueForKey:@"shortName"]];
}


@end
