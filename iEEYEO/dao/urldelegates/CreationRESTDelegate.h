//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import "BaseRESTDelegate.h"

@class EEYEOIdObject;
@class RESTWriter;

@interface CreationRESTDelegate : BaseRESTDelegate
- (id)initWithRequest:(NSMutableURLRequest *)request AndEntity:(EEYEOIdObject *)entity AndWriter:(RESTWriter *)writer;
@end