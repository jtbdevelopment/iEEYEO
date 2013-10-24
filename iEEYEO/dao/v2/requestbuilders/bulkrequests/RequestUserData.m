//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "RequestUserData.h"


@implementation RequestUserData {

}
- (NSURLRequest *)createNSURLRequest {
    NSURL *url = [[NSURL alloc] initWithString:[self restBaseURL]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    return request;
}
@end