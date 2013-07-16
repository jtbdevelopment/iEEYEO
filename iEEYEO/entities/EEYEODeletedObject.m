//
//  EEYEODeletedObject.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "EEYEODeletedObject.h"


@implementation EEYEODeletedObject

@dynamic deletedId;

- (void)loadFromDictionary:(NSDictionary *)dictionary {
    [super loadFromDictionary:dictionary];
    [self setDeletedId:[dictionary valueForKey:JSON_DELETED_ID]];
}

- (void)writeToDictionary:(NSMutableDictionary *)dictionary {
    [super writeToDictionary:dictionary];
    [dictionary setValue:[self deletedId] forKey:JSON_DELETED_ID];
}


@end
