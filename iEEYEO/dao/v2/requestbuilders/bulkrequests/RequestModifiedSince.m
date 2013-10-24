//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "RequestModifiedSince.h"
#import "EEYEORemoteDataStore.h"


@implementation RequestModifiedSince {

}
- (NSString *)restLastModifiedSinceURL {
    return [[self restUserURL] stringByAppendingFormat:@"ModifiedSince/%@", [[EEYEORemoteDataStore instance] lastUpdateFromServerAsString]];
}

- (NSURLRequest *)createNSURLRequest {
    NSURL *url = [[NSURL alloc] initWithString:[self restLastModifiedSinceURL]];
    return [[NSMutableURLRequest alloc] initWithURL:url];
}


@end