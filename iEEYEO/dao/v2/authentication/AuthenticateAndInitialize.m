//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "AuthenticateAndInitialize.h"
#import "EEYEOLocalDataStore.h"
#import "RemoteStoreUpdateProcessor.h"
#import "RequestUserData.h"


@implementation AuthenticateAndInitialize

+ (BOOL)authenticateUser:(NSString *)userId WithPassword:(NSString *)password AndBaseURL:(NSString *)baseURL {
    if ([super authenticateUser:userId WithPassword:password AndBaseURL:baseURL]) {
        EEYEOLocalDataStore *localDataStore = [EEYEOLocalDataStore instance];
        [localDataStore setLogin:userId];
        [localDataStore setPassword:password];
        [localDataStore setWebsite:baseURL];

        NSURLResponse *response;
        NSError *error;

        NSURLRequest *userRequest = [[[RequestUserData alloc] init] createNSURLRequest];
        NSData *userData = [NSURLConnection sendSynchronousRequest:userRequest returningResponse:&response error:&error];
        if ([[response MIMEType] isEqualToString:@"application/json"]) {
            id updateUnknown = [NSJSONSerialization JSONObjectWithData:userData options:kNilOptions error:&error];
            [RemoteStoreUpdateProcessor processUpdates:updateUnknown];
            return YES;
        }
        return NO;
    }
    return NO;
}

@end