//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>

@class RequestCoordinator;


@interface EEYEORemoteQueue : NSObject
@property(nonatomic) BOOL networkAvailable;

+ (EEYEORemoteQueue *)instance;

- (void)resetQueue;

- (void)addRequest:(RequestCoordinator *)requestCoordinator;

- (void)processNextRequest;

- (void)closeRequest:(RequestCoordinator *)requestCoordinator;

- (void)resubmitRequest:(RequestCoordinator *)requestCoordinator;

- (void)resubmitTimer:(NSTimer *)timer;
@end