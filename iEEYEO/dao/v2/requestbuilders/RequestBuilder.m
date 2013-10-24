//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "EEYEORemoteDataStore.h"
#import "EntityRelatedRequest.h"
#import "EEYEOLocalDataStore.h"


@implementation RequestBuilder

- (NSString *)restBaseURL {
    //  TODO - more efficient
    return [[[EEYEOLocalDataStore instance] website] stringByAppendingFormat:@"REST/v2/users/"];
}

- (NSURLRequest *)createNSURLRequest {
    return nil;
}

- (NSString *)restUserURL {
    return [[self restBaseURL] stringByAppendingFormat:@"%@/", [[EEYEORemoteDataStore instance] getCurrentUserID]];
}

@end