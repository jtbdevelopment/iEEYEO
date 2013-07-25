//
//  EEYEODeletedObject.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "EEYEODeletedObject.h"


@implementation EEYEODeletedObject

@dynamic deletedId;

- (BOOL)loadFromDictionary:(NSDictionary *)dictionary {
    [self setDeletedId:[dictionary valueForKey:JSON_DELETED_ID]];
    return [super loadFromDictionary:dictionary];
}

- (void)writeToDictionary:(NSMutableDictionary *)dictionary {
    [super writeToDictionary:dictionary];
    [dictionary setValue:[self deletedId] forKey:JSON_DELETED_ID];
}


@end
