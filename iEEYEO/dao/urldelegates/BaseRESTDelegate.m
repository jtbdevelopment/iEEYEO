//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "BaseRESTDelegate.h"
#import "EEYEORemoteDataStore.h"
#import "EEYEOLocalDataStore.h"
#import "EEYEODeletedObject.h"
#import "NSDateWithMillis.h"

#if TARGET_IPHONE_SIMULATOR
@interface NSURLRequest(Private)
+(void)setAllowsAnyHTTPSCertificate:(BOOL)inAllow forHost:(NSString *)inHost;
@end
#endif


@implementation BaseRESTDelegate {
@protected
    NSMutableData *_data;
    NSURLResponse *_response;
    NSURLRequest *_request;
@private
    int _retries;
}

@synthesize retries = _retries;

- (id)initWithRequest:(NSURLRequest *)request {
    self = [super init];
    if (self) {
        _data = [[NSMutableData alloc] init];
        _request = request;
        _retries = 0;
    }

    return self;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[EEYEORemoteDataStore instance] requeueWorkItem:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _response = response;
    [_data setLength:0];
}

- (BOOL)authenticate {
    BOOL authenticated = [self authenticateConnection:[[EEYEOLocalDataStore instance] login] password:[[EEYEOLocalDataStore instance] password] AndBaseURL:[[EEYEOLocalDataStore instance] website]];
    if (authenticated && _request) {
        [self submitRequest];
    }
    return authenticated;
}

- (BOOL)authenticateConnection:(NSString *)userId password:(NSString *)password AndBaseURL:(NSString *)baseURL {
    BOOL authenticated = NO;
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
            authenticated = YES;
        } else {
            [[EEYEORemoteDataStore instance] requeueWorkItem:self];
        }
    } else {
        [[EEYEORemoteDataStore instance] requeueWorkItem:self];
    }
    return authenticated;
}

- (void)submitRequest {
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self];
    if (!connection) {
        [[EEYEORemoteDataStore instance] requeueWorkItem:self];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([[_response MIMEType] isEqualToString:@"text/html"]) {
        NSString *html = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        if ([html rangeOfString:@"javascript"].location == NSNotFound) {
            [[EEYEORemoteDataStore instance] requeueWorkItem:self];
        } else {
            [self authenticate];
        }
    } else {
        if ([_response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) _response;
            if ([httpResponse statusCode] == 201) {
                NSString *location = [[httpResponse allHeaderFields] valueForKey:@"Location"];
                NSURL *newURL = [[NSURL alloc] initWithString:location];
                _request = [[NSURLRequest alloc] initWithURL:newURL];
                NSURLConnection *redirect = [NSURLConnection connectionWithRequest:_request delegate:self];
                if (!redirect) {
                    [[EEYEORemoteDataStore instance] requeueWorkItem:self];
                }
                return;
            }
        }
        [self doProcessing];
    }
}

- (void)doProcessing {
    [self processUpdatesFromServer:_data];
    [[EEYEORemoteDataStore instance] completeWorkItem:self];
}

- (id)getObjectToUpdateWithType:(NSString *)localType AndId:(NSString *)id {
    return [[EEYEOLocalDataStore instance] findOrCreate:localType withId:id];
}

- (id)processJSONEntity:(NSDictionary *)update {
    //  TODO - this works under an assumptions which are wrong
    //    a.  That there are no active entities linked to archived entities
    //         (i.e. no active observation on an archived student)
    //         not always true with current server
    EEYEOLocalDataStore *localDataStore = [EEYEOLocalDataStore instance];
    NSString *entityType = [update objectForKey:JSON_ENTITY];
    if ([entityType isEqualToString:JAVA_DELETED]) {
        EEYEODeletedObject *deletedObject = [localDataStore create:DELETEDENTITY];
        [deletedObject loadFromDictionary:update];
        EEYEOIdObject *local = [localDataStore find:APPUSEROWNEDENTITY withId:[deletedObject deletedId]];
        if (local) {
            [localDataStore deleteUpdateFromRemoteStore:local];
        }
        [localDataStore deleteUpdateFromRemoteStore:deletedObject];
        return local;
    } else {
        NSString *localType = [[EEYEORemoteDataStore javaToIOSEntityMap] valueForKey:entityType];
        if (!localType) {
            return nil;
        }
        NSString *id = [update objectForKey:JSON_ID];
        EEYEOIdObject *local = [self getObjectToUpdateWithType:localType AndId:id];
        if (local.dirty) {
            NSDateWithMillis *remoteDate = [NSDateWithMillis dateFromJodaTime:[update valueForKey:JSON_MODIFICATIONTS]];
            NSComparisonResult result = [remoteDate compare:local.modificationTimestampToNSDateWithMillis];
            switch (result) {
                case NSOrderedSame:
                case NSOrderedDescending:
                    break;
                case NSOrderedAscending:
                    [localDataStore saveToLocalStore:local];
                    return nil;
            }
        }
        if ([local loadFromDictionary:update]) {
            [localDataStore updateFromRemoteStore:local];
            if ([local isKindOfClass:[EEYEOAppUserOwnedObject class]] && [(EEYEOAppUserOwnedObject *) local archived]) {
                [localDataStore deleteUpdateFromRemoteStore:local];
            }
            return local;
        } else {
            [localDataStore undoChanges];
            //  TODO - maybe queue for re-processing
            return nil;
        }
    }
}

- (NSDateWithMillis *)processUpdatesFromServer:(NSData *)data {
    @synchronized (self) {
        NSError *error;
        id updateUnknown = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSArray *updates;
        if ([updateUnknown isKindOfClass:[NSDictionary class]]) {
            updates = [[NSArray alloc] initWithObjects:updateUnknown, nil];
        } else {
            updates = updateUnknown;
        }
        NSDateWithMillis *lastModTS = [[NSDateWithMillis alloc] init];
        for (NSDictionary *update in updates) {
            EEYEOIdObject *local = [self processJSONEntity:update];
            if (local) {
                NSDateWithMillis *modified = [local modificationTimestampToNSDateWithMillis];
                if ([modified compare:lastModTS] == NSOrderedDescending) {
                    lastModTS = modified;
                }
            }
        }
        return lastModTS;
    }
}
@end