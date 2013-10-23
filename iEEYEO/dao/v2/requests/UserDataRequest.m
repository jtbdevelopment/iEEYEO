//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "UserDataRequest.h"


@implementation UserDataRequest {

}
- (NSURLRequest *)createRequest {
    NSURL *url = [[NSURL alloc] initWithString:[self restBaseURL]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    return request;
}
@end