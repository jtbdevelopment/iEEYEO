//
//  EEYEODeletedObject.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EEYEOAppUserOwnedObject.h"


@interface EEYEODeletedObject : EEYEOAppUserOwnedObject

@property(nonatomic, retain) NSString *deletedId;

@end
