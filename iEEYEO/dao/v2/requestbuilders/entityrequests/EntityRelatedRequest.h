//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import "RequestBuilder.h"

@class EEYEOIdObject;


@interface EntityRelatedRequest : RequestBuilder
@property(nonatomic, retain) EEYEOIdObject *entity;

- (id)initForEntity:(EEYEOIdObject *)entity;

- (NSString *)restEntityIdURL:(NSString *)id1;

- (NSURLRequest *)createRequestToServer:(EEYEOIdObject *)entity method:(NSString *)method urlString:(NSString *)urlString;
@end