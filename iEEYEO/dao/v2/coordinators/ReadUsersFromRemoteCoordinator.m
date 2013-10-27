//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "ReadUsersFromRemoteCoordinator.h"
#import "RequestBuilder.h"
#import "RequestUserData.h"
#import "RemoteStoreUpdateProcessor.h"


@implementation ReadUsersFromRemoteCoordinator {

}
- (BOOL)processResults:(NSData *)data {
    id json = [self convertToJSON:data];
    if ([RemoteStoreUpdateProcessor processUpdates:json] == nil) {
        return NO;
    }
    [self markComplete];
    return YES;
}

- (RequestBuilder *)generateRequestBuilder {
    return [[RequestUserData alloc] init];
}

@end