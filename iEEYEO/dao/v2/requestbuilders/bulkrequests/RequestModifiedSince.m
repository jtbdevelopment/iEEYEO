//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "RequestModifiedSince.h"
#import "EEYEORemoteDataStore.h"


@implementation RequestModifiedSince {

}
- (NSString *)restLastModifiedSinceURL {
    EEYEORemoteDataStore *store = [EEYEORemoteDataStore instance];
    return [[self restUserURL] stringByAppendingFormat:@"ModifiedSince/%@?lastIdSeen=%@", [store lastUpdateFromServerAsString], [store lastUpdateIdFromServer]];
}

- (NSURLRequest *)createNSURLRequest {
    NSURL *url = [[NSURL alloc] initWithString:[self restLastModifiedSinceURL]];
    return [[NSMutableURLRequest alloc] initWithURL:url];
}


@end