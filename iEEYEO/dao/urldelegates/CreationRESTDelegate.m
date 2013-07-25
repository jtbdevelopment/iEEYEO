//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "CreationRESTDelegate.h"
#import "EEYEOIdObject.h"


@implementation CreationRESTDelegate {
@private
    EEYEOIdObject *_entity;

}

//  TODO - verify presumption that request is for local object
- (id)getObjectToUpdateWithType:(NSString *)localType AndId:(NSString *)id {
    return _entity;
}

- (id)initWithRequest:(NSURLRequest *)request AndEntity:(EEYEOIdObject *)entity {
    self = [super initWithRequest:request];
    if (self) {
        _entity = entity;
    }

    return self;
}

@end