//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import "RequestCoordinator.h"


@interface WriteToRemoteCoordinator : RequestCoordinator
- (instancetype)initWithCategory:(NSString *)category;

+ (instancetype)serverWithCategory:(NSString *)category;

@end