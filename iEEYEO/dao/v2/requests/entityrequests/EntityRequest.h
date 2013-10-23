//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import "BaseRequest.h"

@class EEYEOIdObject;


@interface EntityRequest : BaseRequest
@property(nonatomic, retain) EEYEOIdObject *entity;

- (id)initForEntity:(EEYEOIdObject *)entity;

- (NSString *)restUserURL;

- (NSString *)restEntityIdURL:(NSString *)id1;

- (NSURLRequest *)createRequestToServer:(EEYEOIdObject *)entity method:(NSString *)method urlString:(NSString *)urlString;
@end