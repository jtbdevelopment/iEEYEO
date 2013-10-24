//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "RequestCreate.h"


@implementation RequestCreate {

}
- (NSURLRequest *)createNSURLRequest {
    return [self createRequestToServer:[self entity] method:@"POST" urlString:[self restUserURL]];
}


@end