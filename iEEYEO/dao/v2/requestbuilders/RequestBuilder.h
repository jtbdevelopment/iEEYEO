//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>


@interface RequestBuilder : NSObject

- (NSString *)restBaseURL;

- (NSURLRequest *)createNSURLRequest;

- (NSString *)restUserURL;
@end