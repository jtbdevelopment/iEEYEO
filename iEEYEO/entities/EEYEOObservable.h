//
//  EEYEOObservable.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EEYEOAppUserOwnedObject.h"


@interface EEYEOObservable : EEYEOAppUserOwnedObject

//  TODO - computed
@property(nonatomic) NSTimeInterval lastObservationTimestamp;

- (NSString *)desc;

@end
