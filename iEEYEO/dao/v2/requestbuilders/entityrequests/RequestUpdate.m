//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "RequestUpdate.h"
#import "EEYEOIdObject.h"


@implementation RequestUpdate {

}
- (NSURLRequest *)createNSURLRequest {
    return [self createRequestToServer:[self entity] method:@"PUT" urlString:[self restEntityIdURL:[[self entity] id]]];
}
@end