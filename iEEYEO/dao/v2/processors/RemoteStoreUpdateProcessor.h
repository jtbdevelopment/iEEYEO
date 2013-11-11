//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>

@class NSDateWithMillis;


static NSString *const LASTTIMESTAMPKEY = @"lastTimestamp";

static NSString *const LASTIDKEY = @"lastId";

@interface RemoteStoreUpdateProcessor : NSObject
//  Returns dictionary with two values:
//    last timestamp - key = "lastTimestamp"
//    last id associated with timestamp - key = "lastId";
+ (NSDictionary *)processUpdates:(id)unknownUpdates;
@end