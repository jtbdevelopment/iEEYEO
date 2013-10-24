//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import "BaseCoordinator.h"


@interface WriteToRemoteCoordinator : BaseCoordinator
- (instancetype)initWithCategory:(NSString *)category;

+ (instancetype)serverWithCategory:(NSString *)category;

@end