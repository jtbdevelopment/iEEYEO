//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "Reauthenticator.h"
#import "EEYEOLocalDataStore.h"


@implementation Reauthenticator

+ (BOOL)reauthenticate {
    return [self authenticateUser:[[EEYEOLocalDataStore instance] login] WithPassword:[[EEYEOLocalDataStore instance] password] AndBaseURL:[[EEYEOLocalDataStore instance] website]];
}

+ (BOOL)authenticateUser:(NSString *)userId WithPassword:(NSString *)password AndBaseURL:(NSString *)baseURL {
    NSURL *url = [[NSURL alloc] initWithString:[baseURL stringByAppendingString:@"security/login?_spring_security_remember_me=true"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

#if TARGET_IPHONE_SIMULATOR
    NSString *host = [url host];
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:host];
#endif

    NSString *form = [NSString stringWithFormat:@"login=%@&password=%@&_spring_security_remember_me=true", userId, password];
    char const *bytes = [form UTF8String];
    [request setHTTPBody:[NSData dataWithBytes:bytes length:[form length]]];
    NSURLResponse *response;
    NSError *error;
    NSData *loginData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if ([response.MIMEType isEqualToString:@"text/plain"]) {
        NSString *string = [[NSString alloc] initWithData:loginData encoding:NSUTF8StringEncoding];
        if ([string isEqualToString:@"SUCCESS"]) {
            return YES;
        }
    }
    return NO;
}

@end