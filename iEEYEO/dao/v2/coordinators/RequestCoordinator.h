//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>

@class RequestBuilder;


@interface RequestCoordinator : NSObject <NSURLConnectionDataDelegate>
@property NSUInteger attempts;
@property(nonatomic, retain) NSURLRequest *activeURLRequest;
@property(nonatomic, retain) RequestBuilder *activeRequestBuilder;

- (BOOL)doWork;

- (RequestBuilder *)generateRequestBuilder;

- (BOOL)processResults:(NSData *)data;

- (BOOL)makeRequest;

- (void)markComplete;

- (id)convertToJSON:(NSData *)data;
@end