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

- (BOOL)loadFromDictionary:(NSDictionary *)dictionary {
    [self setName:[dictionary valueForKey:JSON_DESCRIPTION]];
    return [super loadFromDictionary:dictionary];
}

- (void)writeToDictionary:(NSMutableDictionary *)dictionary {
    [super writeToDictionary:dictionary];
    [dictionary setValue:[self name] forKey:JSON_DESCRIPTION];
}

@end
