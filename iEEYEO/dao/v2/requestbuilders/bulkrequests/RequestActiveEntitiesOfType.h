//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import "RequestBuilder.h"
#import "PagingRequestBuilder.h"


@interface RequestActiveEntitiesOfType : PagingRequestBuilder
@property int pageNumber;

- (instancetype)initWithCategory:(NSString *)category AndPageNumber:(int)pageNumber;

+ (instancetype)requestWithCategory:(NSString *)category AndPageNumber:(int)pageNumber;

@end