//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "InitialAuthenticationDelegate.h"
#import "EEYEORemoteDataStore.h"
#import "EEYEOLocalDataStore.h"


@implementation InitialAuthenticationDelegate {

}
- (BOOL)authenticateConnection:(NSString *)userId password:(NSString *)password AndBaseURL:(NSString *)baseURL {

    if ([super authenticateConnection:userId password:password AndBaseURL:baseURL]) {
        EEYEOLocalDataStore *localDataStore = [EEYEOLocalDataStore instance];
        [localDataStore setLogin:userId];
        [localDataStore setPassword:password];
        [localDataStore setWebsite:baseURL];
        NSURLRequest *users = [[EEYEORemoteDataStore instance] generateUserLoadRequest];
        NSURLResponse *response;
        NSError *error;
        NSData *userData = [NSURLConnection sendSynchronousRequest:users returningResponse:&response error:&error];
        if ([[response MIMEType] isEqualToString:@"application/json"]) {
            [self processUpdatesFromServer:userData];
            return YES;
        }
        return NO;
    }
    return NO;
}

@end