//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "ReadFromRemoteCoordinator.h"
#import "RemoteStoreUpdateProcessor.h"
#import "RequestBuilder.h"
#import "PagingRequestBuilder.h"
#import "EEYEORemoteDataStore.h"


@implementation ReadFromRemoteCoordinator {

}
- (BOOL)processResults:(NSData *)data {
    id json = [self convertToJSON:data];
    if (!json) {
        return NO;
    }

    BOOL moreToFollow;
    NSArray *entities;
    if ([json isKindOfClass:[NSDictionary class]]) {
        NSDictionary *results = (NSDictionary *) json;
        moreToFollow = [[results valueForKey:@"more"] boolValue];
        entities = [results valueForKey:@"entities"];
    } else {
        return NO;
    }

    NSDateWithMillis *lastMillis = [RemoteStoreUpdateProcessor processUpdates:entities];
    if (lastMillis == nil) {
        return NO;
    }
    [[EEYEORemoteDataStore instance] setLastUpdateFromServerWithNSDateWithMillis:lastMillis];

    [self setActiveURLRequest:nil];
    RequestBuilder *requestBuilder = [self activeRequestBuilder];
    if (moreToFollow && [requestBuilder isKindOfClass:[PagingRequestBuilder class]]) {
        [(PagingRequestBuilder *) requestBuilder incrementPage];
    } else {
        [self setActiveRequestBuilder:nil];
    }
    if (![self doWork]) {
        [self markComplete];
    }
    return YES;
}

@end