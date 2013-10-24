//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>

@class RequestCoordinator;


@interface EEYEORemoteQueue : NSObject
+ (EEYEORemoteQueue *)instance;

- (void)processNextRequest;

- (void)closeRequest:(RequestCoordinator *)requestCoordinator;

- (void)resubmitRequest:(RequestCoordinator *)requestCoordinator;

- (void)resubmitTimer:(NSTimer *)timer;
@end