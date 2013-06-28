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

@property(nonatomic) int64_t lastObservationTimestamp;

- (NSString *)desc;
@end
