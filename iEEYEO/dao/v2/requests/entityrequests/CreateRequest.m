//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "CreateRequest.h"


@implementation CreateRequest {

}
- (NSURLRequest *)createRequest {
    return [self createRequestToServer:[self entity] method:@"POST" urlString:[self restUserURL]];
}


@end