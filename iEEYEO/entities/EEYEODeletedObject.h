//
//  EEYEODeletedObject.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EEYEOAppUserOwnedObject.h"


static NSString *const JSON_DELETED_ID = @"deletedId";

@interface EEYEODeletedObject : EEYEOAppUserOwnedObject

@property(nonatomic, retain) NSString *deletedId;

@end
