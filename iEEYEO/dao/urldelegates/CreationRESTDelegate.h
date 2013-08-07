//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import "BaseRESTDelegate.h"

@class EEYEOIdObject;
@class RESTWriter;

@interface CreationRESTDelegate : BaseRESTDelegate
@property(nonatomic, strong) EEYEOIdObject *entity;
@property(nonatomic, strong) RESTWriter *writer;
@property(nonatomic, strong) NSMutableURLRequest *request;

- (id)initWithRequest:(NSMutableURLRequest *)request AndEntity:(EEYEOIdObject *)entity AndWriter:(RESTWriter *)writer;
@end