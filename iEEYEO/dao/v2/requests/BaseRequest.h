//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>


@interface BaseRequest : NSObject
- (NSString *)restBaseURL;

- (NSURLRequest *)createRequest;
@end