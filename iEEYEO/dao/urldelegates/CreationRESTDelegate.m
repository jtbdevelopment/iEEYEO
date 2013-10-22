//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "CreationRESTDelegate.h"
#import "EEYEOIdObject.h"
#import "RESTWriter.h"
#import "EEYEOLocalDataStore.h"
#import "EntityToDictionaryHelper.h"


@implementation CreationRESTDelegate {
@private
    EEYEOIdObject *_entity;
    RESTWriter *_writer;
    NSMutableURLRequest *_request;
}

@synthesize entity = _entity;
@synthesize writer = _writer;
@synthesize request = _request;

//  TODO - verify presumption that request is for local object
- (id)getObjectToUpdateWithType:(NSString *)localType AndId:(NSString *)id {
    return _entity;
}

- (void)submitRequest {
    //  On creates, if we have multiple create, form initially created may not have ids for related objects
    //  This forces rewrites.
    //  This class and super are pointing to same request.
    [[EEYEOLocalDataStore instance] refreshObject:_entity];
    [EntityToDictionaryHelper writeEntity:_entity ToForm:_request];
    [super submitRequest];
}

- (id)initWithRequest:(NSMutableURLRequest *)request AndEntity:(EEYEOIdObject *)entity AndWriter:(RESTWriter *)writer {
    self = [super initWithRequest:request];
    if (self) {
        [self setEntity:entity];
        [self setRequest:request];
        [self setWriter:writer];
    }

    return self;
}

@end