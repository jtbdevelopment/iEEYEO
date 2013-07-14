//
//  EEYEOAppUserOwnedObject.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "EEYEOAppUserOwnedObject.h"
#import "EEYEOLocalDataStore.h"


@implementation EEYEOAppUserOwnedObject

@dynamic archived;
@dynamic appUser;

- (void)loadFromDictionary:(NSDictionary *)dictionary {
    [super loadFromDictionary:dictionary];
    [self setAppUser:[[EEYEOLocalDataStore instance] find:APPUSERENTITY withId:[[dictionary valueForKey:@"appUser"] valueForKey:@"id"]]];
    [self setArchived:(BOOL) [dictionary valueForKey:@"archived"]];
}


@end
