//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "BaseRequest.h"
#import "EEYEOLocalDataStore.h"


@implementation BaseRequest {

}

- (NSString *)restBaseURL {
    //  TODO - more efficient
    return [[[EEYEOLocalDataStore instance] website] stringByAppendingFormat:@"REST/v2/users/"];
}

- (NSURLRequest *)createRequest {
    return nil;
}

@end