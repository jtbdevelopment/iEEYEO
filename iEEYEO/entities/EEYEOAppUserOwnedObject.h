//
//  EEYEOAppUserOwnedObject.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EEYEOIdObject.h"

@class EEYEOAppUser;

static NSString *const JSON_ARCHIVED = @"archived";

static NSString *const JSON_APPUSER = @"appUser";

@interface EEYEOAppUserOwnedObject : EEYEOIdObject

@property(nonatomic) BOOL archived;
@property(nonatomic, retain) EEYEOAppUser *appUser;

@end
