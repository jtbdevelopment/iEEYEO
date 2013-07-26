//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>

@class NSDateWithMillis;


@interface BaseRESTDelegate : NSObject <NSURLConnectionDelegate>
- (id)initWithRequest:(NSURLRequest *)request;

- (id)getObjectToUpdateWithType:(NSString *)localType AndId:(NSString *)id;

- (void)submitRequest;

- (NSDateWithMillis *)processUpdatesFromServer:(NSData *)data;
@end