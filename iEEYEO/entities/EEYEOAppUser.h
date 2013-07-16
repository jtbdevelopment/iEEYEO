//
//  EEYEOAppUser.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EEYEOIdObject.h"

@class EEYEOAppUserOwnedObject;

static NSString *const JSON_ACTIVATED = @"activated";

static NSString *const JSON_ADMIN = @"admin";

static NSString *const JSON_ACTIVE = @"active";

static NSString *const JSON_EMAIL_ADDRESS = @"emailAddress";

static NSString *const JSON_LASTLOGOUT = @"lastLogout";

@interface EEYEOAppUser : EEYEOIdObject

@property(nonatomic) BOOL activated;
@property(nonatomic) BOOL active;
@property(nonatomic) BOOL admin;
@property(nonatomic, retain) NSString *emailAddress;
@property(nonatomic, retain) NSString *firstName;
@property(nonatomic) NSTimeInterval lastLogout;
@property(nonatomic, retain) NSString *lastName;
@property(nonatomic, retain) NSSet *ownedObjects;
@end

@interface EEYEOAppUser (CoreDataGeneratedAccessors)

- (void)addOwnedObjectsObject:(EEYEOAppUserOwnedObject *)value;

- (void)removeOwnedObjectsObject:(EEYEOAppUserOwnedObject *)value;

- (void)addOwnedObjects:(NSSet *)values;

- (void)removeOwnedObjects:(NSSet *)values;

@end
