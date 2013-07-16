//
//  EEYEOAppUserOwnedObject.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EEYEOIdObject.h"

@class EEYEOAppUser, EEYEOPhoto;

static NSString *const JSON_ARCHIVED = @"archived";

static NSString *const JSON_APPUSER = @"appUser";

@interface EEYEOAppUserOwnedObject : EEYEOIdObject

@property(nonatomic) BOOL archived;
@property(nonatomic, retain) EEYEOAppUser *appUser;
@property(nonatomic, retain) NSSet *photos;
@end

@interface EEYEOAppUserOwnedObject (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(EEYEOPhoto *)value;

- (void)removePhotosObject:(EEYEOPhoto *)value;

- (void)addPhotos:(NSSet *)values;

- (void)removePhotos:(NSSet *)values;

@end
