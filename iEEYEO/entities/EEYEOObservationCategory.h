//
//  EEYEOObservationCategory.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EEYEOAppUserOwnedObject.h"


@interface EEYEOObservationCategory : EEYEOAppUserOwnedObject

@property(nonatomic, retain) NSString *desc;
@property(nonatomic, retain) NSString *shortName;

@end
