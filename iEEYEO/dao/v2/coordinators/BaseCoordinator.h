//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>

@class RequestBuilder;


@interface BaseCoordinator : NSObject <NSURLConnectionDataDelegate>
@property(nonatomic, retain) NSURLRequest *activeURLRequest;
@property(nonatomic, retain) RequestBuilder *activeRequestBuilder;

- (BOOL)generateWork;

- (BOOL)processResults:(NSData *)data;

- (BOOL)makeRequest;

- (void)markComplete;
@end