//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "RequestActiveEntitiesOfType.h"


@implementation RequestActiveEntitiesOfType {

@private
    NSString *_category;
    int _pageNumber;
}
@synthesize pageNumber = _pageNumber;

- (instancetype)initWithCategory:(NSString *)category {
    self = [super init];
    if (self) {
        _category = category;
        self.pageNumber = 0;
    }

    return self;
}

- (instancetype)initWithCategory:(NSString *)category AndPageNumber:(int)pageNumber {
    self = [super init];
    if (self) {
        _category = category;
        self.pageNumber = pageNumber;
    }

    return self;
}

+ (instancetype)requestWithCategory:(NSString *)category AndPageNumber:(int)pageNumber {
    return [[self alloc] initWithCategory:category AndPageNumber:pageNumber];
}

+ (instancetype)requestWithCategory:(NSString *)category {
    return [[self alloc] initWithCategory:category AndPageNumber:0];
}


- (void)incrementPage {
    _pageNumber += 1;
}

- (NSURLRequest *)createNSURLRequest {
    NSURL *url = [[NSURL alloc] initWithString:[[self restUserURL] stringByAppendingFormat:@"%@/active?page=%d", _category, _pageNumber]];
    return [[NSURLRequest alloc] initWithURL:url];
}


@end