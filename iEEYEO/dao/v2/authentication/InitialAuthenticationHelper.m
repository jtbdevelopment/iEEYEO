//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "InitialAuthenticationHelper.h"
#import "EEYEOLocalDataStore.h"
#import "EEYEORemoteDataStore.h"
#import "RemoteStoreUpdateProcessor.h"


@implementation InitialAuthenticationHelper

+ (BOOL)authenticateUser:(NSString *)userId WithPassword:(NSString *)password AndBaseURL:(NSString *)baseURL {
    if ([super authenticateUser:userId WithPassword:password AndBaseURL:baseURL]) {
        EEYEOLocalDataStore *localDataStore = [EEYEOLocalDataStore instance];
        [localDataStore setLogin:userId];
        [localDataStore setPassword:password];
        [localDataStore setWebsite:baseURL];
        NSURLRequest *users = [[EEYEORemoteDataStore instance] generateUserLoadRequest];
        NSURLResponse *response;
        NSError *error;
        NSData *userData = [NSURLConnection sendSynchronousRequest:users returningResponse:&response error:&error];
        if ([[response MIMEType] isEqualToString:@"application/json"]) {
            NSError *error;
            id updateUnknown = [NSJSONSerialization JSONObjectWithData:userData options:kNilOptions error:&error];
            [RemoteStoreUpdateProcessor processUpdates:updateUnknown];
            return YES;
        }
        return NO;
    }
    return NO;
}

@end