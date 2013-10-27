//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "EEYEORemoteQueue.h"
#import "RequestCoordinator.h"
#import "EEYEORemoteDataStore.h"
#import "NSDateWithMillis.h"

static const int MAX_ATTEMPTS = 5;

static const int RETRY_TIMER = 30;

@implementation EEYEORemoteQueue {
@private
    NSMutableArray *_workQueue;
    RequestCoordinator *_currentRequest;
    BOOL _networkAvailable;
}

@synthesize networkAvailable = _networkAvailable;

+ (EEYEORemoteQueue *)instance {
    static EEYEORemoteQueue *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[super allocWithZone:nil] init];
        }
    }

    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _workQueue = [[NSMutableArray alloc] init];
        _currentRequest = nil;
        [self setNetworkAvailable:NO];
    }

    return self;
}

- (void)resetQueue {
    @synchronized (self) {
        _currentRequest = nil;
        _workQueue = [[NSMutableArray alloc] init];
    }
}

- (void)addRequest:(RequestCoordinator *)requestCoordinator {
    @synchronized (self) {
        [_workQueue addObject:requestCoordinator];
        if (!_currentRequest) {
            [self processNextRequest];
        }
    }
}

- (void)processNextRequest {
    @synchronized (self) {
        if ([self networkAvailable]) {
            _currentRequest = nil;
            if ([_workQueue count] > 0) {
                _currentRequest = [_workQueue objectAtIndex:0];
                [_workQueue removeObjectAtIndex:0];
                [_currentRequest setAttempts:([_currentRequest attempts] + 1)];
                [_currentRequest doWork];
            }
        }
    }
}

- (void)closeRequest:(RequestCoordinator *)requestCoordinator {
    @synchronized (self) {
        if (_currentRequest != requestCoordinator) {
            return;
        }
        _currentRequest = nil;
        [[EEYEORemoteDataStore instance] setLastServerResyncWithNSDateWithMillis:[NSDateWithMillis dateWithTimeIntervalFromNow:0]];
    }
    [self processNextRequest];
}

- (void)resubmitRequest:(RequestCoordinator *)requestCoordinator {
    @synchronized (self) {
        if (requestCoordinator == _currentRequest) {
            if ([requestCoordinator attempts] <= MAX_ATTEMPTS) {
                [_workQueue insertObject:requestCoordinator atIndex:0];
                [NSTimer scheduledTimerWithTimeInterval:RETRY_TIMER target:self selector:@selector(resubmitTimer:) userInfo:nil repeats:NO];
                return;
            } else {
                NSLog(@"Request has been tried max times already - skipping");
            }
        } else {
            NSLog(@"Current work item not same as completed - how did this happen");
        }
    }
    [self processNextRequest];
}

- (void)resubmitTimer:(NSTimer *)timer {
    [self processNextRequest];
}

@end