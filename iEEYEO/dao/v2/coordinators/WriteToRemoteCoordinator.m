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


@implementation WriteToRemoteCoordinator {
@private
    NSString *_category;
    BOOL isDelete;
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

    isDelete = NO;
    if ([entity isKindOfClass:[EEYEODeletedObject class]]) {
        isDelete = YES;
        return [[RequestDelete alloc] initForEntity:(EEYEODeletedObject *) entity];
    }
    if ([[entity id] isEqualToString:@""]) {
        return [[RequestCreate alloc] initForEntity:entity];
    }
    return [[RequestUpdate alloc] initForEntity:entity];
}

- (BOOL)processResults:(NSData *)data {
    id json = [self convertToJSON:data];
    if (!json) {
        return NO;
    }
    if (isDelete) {
        [[EEYEOLocalDataStore instance] deleteFromLocalStore:entity];
    }
    if ([RemoteStoreUpdateProcessor processUpdates:json] == nil) {
        return NO;
    }
    isDelete = NO;
    entity = nil;
    [self setActiveURLRequest:nil];
    [self setActiveRequestBuilder:nil];
    if (![self doWork]) {
        [self markComplete];
    }
    return YES;
}

@end