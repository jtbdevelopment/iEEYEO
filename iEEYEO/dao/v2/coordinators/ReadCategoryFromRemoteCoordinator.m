//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "ReadCategoryFromRemoteCoordinator.h"
#import "RequestBuilder.h"
#import "RequestActiveEntitiesOfType.h"


@implementation ReadCategoryFromRemoteCoordinator {

@private
    NSString *_category;
}
@synthesize category = _category;

- (instancetype)initWithCategory:(NSString *)category {
    self = [super init];
    if (self) {
        self.category = category;
    }

    return self;
}

+ (instancetype)coordinatorWithCategory:(NSString *)category {
    return [[self alloc] initWithCategory:category];
}

- (RequestBuilder *)generateRequestBuilder {
    return [[RequestActiveEntitiesOfType alloc] initWithCategory:_category];
}
@end