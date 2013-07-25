//
//  EEYEOStudent.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "EEYEOStudent.h"
#import "EEYEOLocalDataStore.h"
#import "EEYEOClassList.h"


@implementation EEYEOStudent

@dynamic firstName;
@dynamic lastName;
@dynamic classLists;

- (NSString *)desc {
    NSMutableString *firstLast = [[NSMutableString alloc] initWithString:[self firstName]];
    if (self.lastName) {
        [firstLast appendString:@" "];
        [firstLast appendString:[self lastName]];
    }
    return firstLast;
}

- (void)writeToDictionary:(NSMutableDictionary *)dictionary {
    [super writeToDictionary:dictionary];
    [dictionary setValue:[self lastName] forKey:JSON_LAST_NAME];
    [dictionary setValue:[self firstName] forKey:JSON_FIRST_NAME];
    NSMutableArray *classes = [[NSMutableArray alloc] init];
    for (EEYEOClassList *classList in [self classLists]) {
        [self writeSubobject:classList ToArray:classes];
    }
    [dictionary setValue:classes forKey:JSON_CLASSLISTS];
}

- (BOOL)loadFromDictionary:(NSDictionary *)dictionary {
    [self setFirstName:[dictionary valueForKey:JSON_FIRST_NAME]];
    [self setLastName:[dictionary valueForKey:JSON_LAST_NAME]];
    for (NSDictionary *classList in [dictionary valueForKey:JSON_CLASSLISTS]) {
        EEYEOClassList *value = [[EEYEOLocalDataStore instance] find:CLASSLISTENTITY withId:[classList valueForKey:JSON_ID]];
        if (value) {
            [self addClassListsObject:value];
        } else {
            return NO;
        }
    }
    return [super loadFromDictionary:dictionary];
}

@end
