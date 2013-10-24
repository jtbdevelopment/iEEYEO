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

- (BOOL)generateWork {
    if ([self activeURLRequest]) {
        return [self makeRequest];
    }
    EEYEOIdObject *entity = [[EEYEOLocalDataStore instance] getNextDirtyEntityOfType:_category];
    if (!entity) {
        return NO;
    }
    [self setActiveRequestBuilder:[self getRequestBuilder:entity]];
    return [self makeRequest];
}

- (BOOL)processResults:(NSData *)data {
    NSError *error;
    id updateUnknown = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error) {
        return NO;
    }
    if ([RemoteStoreUpdateProcessor processUpdates:updateUnknown] == nil) {
        return NO;
    }
    [self setActiveURLRequest:nil];
    if (![self generateWork]) {
        [self markComplete];
    }
    return YES;
}

- (RequestBuilder *)getRequestBuilder:(EEYEOIdObject *)entity {
    if ([entity isKindOfClass:[EEYEODeletedObject class]]) {
        return [[RequestDelete alloc] initForEntity:(EEYEODeletedObject *) entity];
    }
    if ([[entity id] isEqualToString:@""]) {
        return [[RequestCreate alloc] initForEntity:entity];
    }
    return [[RequestUpdate alloc] initForEntity:entity];
}

@end