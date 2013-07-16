//
//  EEYEOClassList.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "EEYEOClassList.h"


@implementation EEYEOClassList

@dynamic name;
@dynamic students;

- (NSString *)desc {
    return [self name];
}

- (void)loadFromDictionary:(NSDictionary *)dictionary {
    [super loadFromDictionary:dictionary];
    [self setName:[dictionary valueForKey:JSON_DESCRIPTION]];
}

- (void)writeToDictionary:(NSMutableDictionary *)dictionary {
    [super writeToDictionary:dictionary];
    [dictionary setValue:[self name] forKey:JSON_DESCRIPTION];
}

@end
