//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "UpdatesFromServerRESTDelegate.h"
#import "EEYEORemoteDataStore.h"


@implementation UpdatesFromServerRESTDelegate {

}

- (NSDate *)processUpdatesFromServer:(NSData *)data {
    NSDate *date = [super processUpdatesFromServer:data];
    if (date) {
        [[EEYEORemoteDataStore instance] setLastUpdateFromServerWithNSDate:date];
    }
    return date;
}

@end