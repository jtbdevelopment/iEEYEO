//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>


@interface BaseRESTDelegate : NSObject <NSURLConnectionDelegate>
- (id)initWithRequest:(NSURLRequest *)request;

+ (void)authenticateAndRerequest:(NSURLRequest *)rerequest;

+ (NSDate *)processUpdatesFromServer:(NSData *)data;
@end