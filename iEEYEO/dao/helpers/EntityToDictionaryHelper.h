//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>

@class EEYEORemoteDataStore;
@class EEYEOIdObject;


@interface EntityToDictionaryHelper : NSObject
+ (void)writeEntity:(EEYEOIdObject *)entity ToForm:(NSMutableURLRequest *)request;

+ (void)writeDictionary:(NSMutableDictionary *)dictionary ForEntity:(EEYEOIdObject *)entity ToForm:(NSMutableURLRequest *)request;
@end