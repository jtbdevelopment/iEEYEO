//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>

@class EEYEORemoteDataStore;
@class EEYEOIdObject;


@interface RESTWriter : NSObject
- (id)initForRemoteStore:(EEYEORemoteDataStore *)instance;

- (void)saveEntityToRemote:(EEYEOIdObject *)object;
@end