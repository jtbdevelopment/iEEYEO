//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "UpdateRequest.h"
#import "EEYEOIdObject.h"


@implementation UpdateRequest {

}
- (NSURLRequest *)createRequest {
    return [self createRequestToServer:[self entity] method:@"PUT" urlString:[self restEntityIdURL:[[self entity] id]]];
}
@end