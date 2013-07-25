//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import "BaseRESTDelegate.h"

@class EEYEODeletedObject;


@interface DeletionRESTDelegate : BaseRESTDelegate
- (id)initWithDeletedObject:(EEYEODeletedObject *)deletedObject AndRequest:(NSURLRequest *)request;
@end