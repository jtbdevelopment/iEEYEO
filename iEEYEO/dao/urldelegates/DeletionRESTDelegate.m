//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "DeletionRESTDelegate.h"
#import "EEYEODeletedObject.h"
#import "EEYEOLocalDataStore.h"
#import "NSDateWithMillis.h"


@implementation DeletionRESTDelegate {
@private
    EEYEODeletedObject *_deleted;
}

- (id)initWithDeletedObject:(EEYEODeletedObject *)deletedObject AndRequest:(NSURLRequest *)request {
    self = [super initWithRequest:request];
    if (self) {
        _deleted = deletedObject;
    }
    return self;
}

- (NSDateWithMillis *)processUpdatesFromServer:(NSData *)data {
    [[EEYEOLocalDataStore instance] deleteFromLocalStore:_deleted];
    return [super processUpdatesFromServer:data];
}

@end