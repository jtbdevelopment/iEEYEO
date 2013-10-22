//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>


@interface ReauthenticationHelper : NSObject
+ (BOOL)authenticateUser:(NSString *)userId WithPassword:(NSString *)password AndBaseURL:(NSString *)baseURL;
@end