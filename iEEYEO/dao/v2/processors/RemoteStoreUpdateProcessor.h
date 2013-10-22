//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>

@class NSDateWithMillis;


@interface RemoteStoreUpdateProcessor : NSObject
+ (NSDateWithMillis *)processUpdates:(id)unknownUpdates;
@end