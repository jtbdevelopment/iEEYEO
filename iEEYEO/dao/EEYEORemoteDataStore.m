//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "EEYEORemoteDataStore.h"
#import "EEYEOObservationCategory.h"
#import "EEYEOLocalDataStore.h"


@implementation EEYEORemoteDataStore {
@private
    NSMutableData *_data;
    NSString *_currentUser;
}
- (id)init {
    self = [super init];
    if (self) {
        _data = [[NSMutableData alloc] init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if (![userDefaults stringForKey:USER_ID_KEY]) {
            //  TODO
            [userDefaults setObject:@"4028810e3f0758cf013f075939790000" forKey:USER_ID_KEY];
        }
        _currentUser = [userDefaults stringForKey:USER_ID_KEY];
        if (![userDefaults stringForKey:LAST_MODTS_KEY]) {
            [userDefaults setObject:@"2013-01-01" forKey:LAST_MODTS_KEY];
        }
        [userDefaults synchronize];
    }

    return self;
}

- (NSString *)lastModifiedURL {
    NSString *lastModificationFromServer = [[NSUserDefaults standardUserDefaults] stringForKey:LAST_MODTS_KEY];
    return [BASE_REST_USER_URL stringByAppendingFormat:@"%@/ModifiedSince/%@", _currentUser, lastModificationFromServer];
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self instance];
}

+ (EEYEORemoteDataStore *)instance {
    static EEYEORemoteDataStore *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[super allocWithZone:nil] init];
        }
    }

    return _instance;
}

- (void)loadData {
    NSURL *url = [[NSURL alloc] initWithString:[self lastModifiedURL]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection) {
        //  TODO
        NSLog(@"Failed");
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //  TODO
    NSLog(@"Failed with error %@", error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //  TODO - only received on authentication failure
    if ([[response MIMEType] isEqualToString:@"text/html"]) {
        NSLog(@"Cancelling due to html type");
        NSURLRequest *currentRequest = [connection currentRequest];
        [connection cancel];
        [self authenticate:currentRequest];

    } else {
        [_data setLength:0];
    }
}

- (void)authenticate:(NSURLRequest *)currentRequest {
    NSURL *url = [[NSURL alloc] initWithString:[BASE_REST_URL stringByAppendingString:@"security/login?_spring_security_remember_me=true"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    //  TODO
    NSString *form = @"login=x@x&password=xx&_spring_security_remember_me=true";
    char const *bytes = [form UTF8String];
    [request setHTTPBody:[NSData dataWithBytes:bytes length:[form length]]];
    NSURLResponse *response;
    NSError *error;
    NSData *loginData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if ([response.MIMEType isEqualToString:@"text/plain"]) {
        NSString *string = [[NSString alloc] initWithData:loginData encoding:NSUTF8StringEncoding];
        if ([string isEqualToString:@"SUCCESS"]) {
            NSLog(@"Login success - resending request");
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:currentRequest delegate:self];
            if (!connection) {
                //  TODO
                NSLog(@"Failed");
            }
        } else {
            //  TODO
            NSLog(@"Failure");
        }
    } else {
        //  TODO
        NSLog(@"Got unexpected login mimetype:%@", [response MIMEType]);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error = nil;
    NSArray *updates = [NSJSONSerialization JSONObjectWithData:_data options:kNilOptions error:&error];
    NSLog(@"%@", updates);
    for (NSDictionary *update in updates) {
        NSString *entityType = [update objectForKey:@"entityType"];
        if ([entityType isEqualToString:@"com.jtbdevelopment.e_eye_o.entities.ObservationCategory"]) {
            NSString *id = [update objectForKey:@"id"];
            EEYEOLocalDataStore *store = [EEYEOLocalDataStore instance];
            EEYEOObservationCategory *category = [store findOrCreate:CATEGORYENTITY withId:id];
            if (category.dirty) {
                NSLog(@"Conflict");
            }
            [category loadFromDictionary:update];
            [store updateFromRemoteStore:category];
        }
    }
}


@end