//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import "BaseRESTDelegate.h"

@class EEYEOIdObject;


@interface CreationRESTDelegate : BaseRESTDelegate
- (id)initWithRequest:(NSURLRequest *)request AndEntity:(EEYEOIdObject *)entity;
@end