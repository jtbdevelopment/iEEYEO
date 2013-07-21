//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "BaseRESTDelegate.h"
#import "EEYEORemoteDataStore.h"
#import "EEYEOLocalDataStore.h"
#import "EEYEODeletedObject.h"


@implementation BaseRESTDelegate {
@protected
    NSMutableData *_data;
    NSURLResponse *_response;
    NSURLRequest *_originalRequest;
}

- (id)initWithRequest:(NSURLRequest *)request {
    self = [super init];
    if (self) {
        _data = [[NSMutableData alloc] init];
        _originalRequest = request;
    }

    return self;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //  TODO
    NSLog(@"Failed with error %@", error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _response = response;

    [_data setLength:0];
}

+ (void)authenticateAndRerequest:(NSURLRequest *)rerequest {
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
            if (rerequest) {
                NSLog(@"Login success - resending request");
                NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:rerequest delegate:self];
                if (!connection) {
                    //  TODO
                    NSLog(@"Failed");
                }
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
    if ([[_response MIMEType] isEqualToString:@"text/html"]) {
        NSString *html = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        if ([html rangeOfString:@"javascript"].location == NSNotFound) {
            NSLog(@"Unexpected response:  %@", html);
        } else {
            [BaseRESTDelegate authenticateAndRerequest:_originalRequest];
        }
    } else {
        if ([_response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) _response;
            if ([httpResponse statusCode] == 201) {
                NSString *location = [[httpResponse allHeaderFields] valueForKey:@"Location"];
                NSURL *newURL = [[NSURL alloc] initWithString:location];
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:newURL];
                NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
                if (connection) {
                    NSLog(@"201 redirect to %@", newURL);
                } else {
                    //  TODO
                    NSLog(@"201 redirect to %@ failed", newURL);
                }
                return;
            }
        }
        [self doProcessing];
    }
}

- (NSDate *)doProcessing {
    return [BaseRESTDelegate processUpdatesFromServer:_data];
}

+ (id)processJSONEntity:(NSDictionary *)update {
    EEYEOLocalDataStore *localDataStore = [EEYEOLocalDataStore instance];
    NSString *entityType = [update objectForKey:JSON_ENTITY];
    if ([entityType isEqualToString:JAVA_DELETED]) {
        EEYEODeletedObject *deletedObject = [localDataStore create:DELETEDENTITY];
        [deletedObject loadFromDictionary:update];
        EEYEOIdObject *local = [localDataStore find:APPUSEROWNEDENTITY withId:[deletedObject deletedId]];
        if (local) {
            NSLog(@"Deleting %@", [deletedObject deletedId]);
            [localDataStore deleteUpdateFromRemoteStore:local];
        } else {
            NSLog(@"Deleted Id %@ not found locally - probably ok", [deletedObject deletedId]);
        }
        [localDataStore deleteUpdateFromRemoteStore:deletedObject];
        return local;
    } else {
        NSString *localType = [[EEYEORemoteDataStore javaToIOSEntityMap] valueForKey:entityType];
        if (!localType) {
            NSLog(@"Unknown entity type %@", entityType);
            return nil;
        }
        NSString *id = [update objectForKey:JSON_ID];
        EEYEOIdObject *local = [localDataStore findOrCreate:localType withId:id];
        if (local.dirty) {
            NSDate *remoteDate = [EEYEOIdObject fromJodaDateTime:[update valueForKey:JSON_MODIFICATIONTS]];
            NSComparisonResult result = [remoteDate compare:local.modificationTimestampToNSDate];
            switch (result) {
                case NSOrderedAscending:
                    NSLog(@"Remote more recent - take it");
                    break;
                case NSOrderedDescending:
                    NSLog(@"Local more recent - skip remote and remark local as dirty");
                    [localDataStore saveToLocalStore:local];
                    return nil;
                case NSOrderedSame:
                    NSLog(@"Virtually impossible");
                    break;
            }
            //  TODO
            NSLog(@"Conflict");
        }
        [local loadFromDictionary:update];
        [localDataStore updateFromRemoteStore:local];
        if ([local isKindOfClass:[EEYEOAppUserOwnedObject class]] && [(EEYEOAppUserOwnedObject *) local archived]) {
            [localDataStore deleteUpdateFromRemoteStore:local];
        } else {
            NSMutableDictionary *rewrite = [[NSMutableDictionary alloc] init];
            [local writeToDictionary:rewrite];
            NSLog(@"%@", update);
            NSLog(@"%@", rewrite);
        }
        return local;
    }
}

+ (NSDate *)processUpdatesFromServer:(NSData *)data {
    static NSObject *lock = [[NSObject alloc] init];
    @synchronized (<#lock#>) {
        NSError *error;
        id updateUnknown = [NSJSONSerialization JSONObjectWithData:data options:nil error:&error];
        NSArray *updates;
        if ([updateUnknown isKindOfClass:[NSDictionary class]]) {
            updates = [[NSArray alloc] initWithObjects:updateUnknown, nil];
        } else {
            updates = updateUnknown;
        }
        NSLog(@"%@", updates);
        NSDate *lastModTS = [[NSDate alloc] initWithTimeIntervalSince1970:0];
        for (NSDictionary *update in updates) {
            EEYEOIdObject *local = [BaseRESTDelegate processJSONEntity:update];
            if (local) {
                NSDate *modified = [local modificationTimestampToNSDate];
                if ([modified compare:lastModTS] == NSOrderedDescending) {
                    lastModTS = modified;
                }
            }
        }
        return lastModTS;
    }
}
@end