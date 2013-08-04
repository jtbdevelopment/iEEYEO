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

- (void)writeDictionaryAsForm:(NSMutableURLRequest *)request dictionary:(NSMutableDictionary *)dictionary forEntity:(EEYEOIdObject *)entity;

- (NSMutableDictionary *)getDictionary:(EEYEOIdObject *)entity;
@end