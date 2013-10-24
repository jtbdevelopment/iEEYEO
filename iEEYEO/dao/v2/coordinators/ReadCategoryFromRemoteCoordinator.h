//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import "ReadFromRemoteCoordinator.h"


@interface ReadCategoryFromRemoteCoordinator : ReadFromRemoteCoordinator
@property(nonatomic, retain) NSString *category;

- (instancetype)initWithCategory:(NSString *)category;

+ (instancetype)coordinatorWithCategory:(NSString *)category;

@end