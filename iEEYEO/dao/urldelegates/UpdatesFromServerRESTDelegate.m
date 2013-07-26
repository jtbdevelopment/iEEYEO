//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "UpdatesFromServerRESTDelegate.h"
#import "EEYEORemoteDataStore.h"
#import "NSDateWithMillis.h"


@implementation UpdatesFromServerRESTDelegate {

}

- (NSDateWithMillis *)processUpdatesFromServer:(NSData *)data {
    NSDateWithMillis *date = [super processUpdatesFromServer:data];
    if (date) {
        [[EEYEORemoteDataStore instance] setLastUpdateFromServerWithNSDateWithMillis:date];
    }
    return date;
}

@end