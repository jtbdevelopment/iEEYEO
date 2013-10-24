//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "ReadUpdatesFromRemoteCoordinator.h"
#import "RequestBuilder.h"
#import "RequestModifiedSince.h"


@implementation ReadUpdatesFromRemoteCoordinator {

}
- (RequestBuilder *)generateRequestBuilder {
    return [[RequestModifiedSince alloc] init];
}

@end