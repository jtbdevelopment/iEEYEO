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
    [self setName:[dictionary valueForKey:JSON_DESCRIPTION]];
    [self setShortName:[dictionary valueForKey:JSON_SHORTNAME]];
}

- (void)writeToDictionary:(NSMutableDictionary *)dictionary {
    [super writeToDictionary:dictionary];
    [dictionary setValue:[self name] forKey:JSON_DESCRIPTION];
    [dictionary setValue:[self shortName] forKey:JSON_SHORTNAME];
}


@end
