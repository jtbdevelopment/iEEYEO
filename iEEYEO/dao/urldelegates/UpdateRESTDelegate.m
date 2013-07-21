//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "UpdateRESTDelegate.h"
#import "EEYEORemoteDataStore.h"


@implementation UpdateRESTDelegate {

}
+ (NSDate *)processUpdatesFromServer:(NSData *)data {
    NSData *date = [super processUpdatesFromServer:data];
    if (date) {
        [[EEYEORemoteDataStore instance] setLastUpdateFromServerWithNSDate:date];
    }
    return date;
}

@end