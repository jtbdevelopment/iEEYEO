//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>


static NSString *const BASE_REST_URL = @"http://192.168.1.141:8080/REST/";
static NSString *const BASE_REST_USER_URL = @"http://192.168.1.141:8080/REST/users/";

static NSString *const USER_ID_KEY = @"userId";

static NSString *const LAST_MODTS_KEY = @"LAST_SERVER_MODTS";

@interface EEYEORemoteDataStore : NSObject <NSURLConnectionDataDelegate>
+ (EEYEORemoteDataStore *)instance;

- (void)loadData;
@end