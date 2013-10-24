//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "RequestDelete.h"
#import "EEYEOIdObject.h"
#import "EEYEODeletedObject.h"


@implementation RequestDelete {

}
- (NSURLRequest *)createNSURLRequest {
    NSURL *url = [[NSURL alloc] initWithString:[self restEntityIdURL:[(EEYEODeletedObject *) [self entity] deletedId]]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"DELETE"];
    return request;
}

@end