//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "WriteToRemoteCoordinator.h"
#import "EEYEOIdObject.h"
#import "EEYEOLocalDataStore.h"
#import "EEYEODeletedObject.h"
#import "RequestBuilder.h"
#import "RequestDelete.h"
#import "RequestCreate.h"
#import "RequestUpdate.h"
#import "RemoteStoreUpdateProcessor.h"


enum WriteType : NSUInteger {
    Create,
    Update,
    Delete
};

@implementation WriteToRemoteCoordinator {
@private
    NSString *_category;
    enum WriteType _writeType;
    EEYEOIdObject *entity;
}

- (instancetype)initWithCategory:(NSString *)category {
    self = [super init];
    if (self) {
        _category = category;
    }

    return self;
}

+ (instancetype)serverWithCategory:(NSString *)category {
    return [[self alloc] initWithCategory:category];
}

- (RequestBuilder *)generateRequestBuilder {
    entity = [[EEYEOLocalDataStore instance] getNextDirtyEntityOfType:_category];
    if (!entity) {
        return nil;
    }

    if ([entity isKindOfClass:[EEYEODeletedObject class]]) {
        _writeType = Delete;
        return [[RequestDelete alloc] initForEntity:(EEYEODeletedObject *) entity];
    }
    if ([[entity id] isEqualToString:@""]) {
        _writeType = Create;
        return [[RequestCreate alloc] initForEntity:entity];
    }
    _writeType = Update;
    return [[RequestUpdate alloc] initForEntity:entity];
}

- (BOOL)processResults:(NSData *)data {
    id json = [self convertToJSON:data];
    if (!json) {
        if (_writeType == Delete) {
            [[EEYEOLocalDataStore instance] deleteFromLocalStore:entity];
        } else {
            return NO;
        }
    }
    if ([RemoteStoreUpdateProcessor processUpdates:json] == nil) {
        return NO;
    }
    if (_writeType == Create) {
        //  processUpdates created new one
        [[EEYEOLocalDataStore instance] deleteFromLocalStore:entity];
    }
    entity = nil;
    [self setActiveURLRequest:nil];
    [self setActiveRequestBuilder:nil];
    if (![self doWork]) {
        [self markComplete];
    }
    return YES;
}

@end