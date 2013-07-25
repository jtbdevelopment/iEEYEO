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
    NSURLRequest *_request;
}

- (id)initWithRequest:(NSURLRequest *)request {
    self = [super init];
    if (self) {
        _data = [[NSMutableData alloc] init];
        _request = request;
    }

    return self;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //  TODO - check
    NSLog(@"Failed with error %@", error);
    [[EEYEORemoteDataStore instance] requeueWorkItem:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _response = response;
    [_data setLength:0];
}

- (void)authenticate {
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
            if (_request) {
                NSLog(@"Login success - resending request");
                [self submitRequest];
            }
        } else {
            //  TODO - check this
            NSLog(@"Failure");

        }
    } else {
        //  TODO
        NSLog(@"Got unexpected login mimetype:%@", [response MIMEType]);
    }
}

- (void)submitRequest {
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self];
    if (!connection) {
        //  TODO - check this
        [[EEYEORemoteDataStore instance] requeueWorkItem:self];
        NSLog(@"Failed");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([[_response MIMEType] isEqualToString:@"text/html"]) {
        NSString *html = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        if ([html rangeOfString:@"javascript"].location == NSNotFound) {
            //  TODO - check
            NSLog(@"Unexpected response:  %@", html);
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
                if (redirect) {
                    NSLog(@"201 redirect to %@", newURL);
                } else {
                    //  TODO - check this logic
                    [[EEYEORemoteDataStore instance] requeueWorkItem:self];
                    NSLog(@"201 redirect to %@ failed", newURL);
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
    //  TODO - this works under a couple of assumptions which are wrong
    //    a.  That there are no active entities linked to archived entities
    //         (i.e. no active observation on an archived student)
    //         not always true with current server
    //    b.  Server implements true rss style feed where all updates come in proper order
    //         (i.e. user creates observation, creates photo for observation and then modifies observation comes as 3 updates)
    //         not true with current server
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
        EEYEOIdObject *local = [self getObjectToUpdateWithType:localType AndId:id];
        if (local.dirty) {
            NSDate *remoteDate = [EEYEOIdObject fromJodaDateTime:[update valueForKey:JSON_MODIFICATIONTS]];
            NSComparisonResult result = [remoteDate compare:local.modificationTimestampToNSDate];
            switch (result) {
                case NSOrderedDescending:
                    NSLog(@"Remote more recent - take it");
                    break;
                case NSOrderedAscending:
                    NSLog(@"Local more recent - skip remote and remark local as dirty");
                    [localDataStore saveToLocalStore:local];
                    return nil;
                case NSOrderedSame:
                    NSLog(@"Virtually impossible");
                    break;
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

- (NSDate *)processUpdatesFromServer:(NSData *)data {
    @synchronized (self) {
        NSError *error;
        id updateUnknown = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSArray *updates;
        if ([updateUnknown isKindOfClass:[NSDictionary class]]) {
            updates = [[NSArray alloc] initWithObjects:updateUnknown, nil];
        } else {
            updates = updateUnknown;
        }
        NSLog(@"%@", updates);
        NSDate *lastModTS = [[NSDate alloc] initWithTimeIntervalSince1970:0];
        for (NSDictionary *update in updates) {
            EEYEOIdObject *local = [self processJSONEntity:update];
            if (local) {
                //  TODO - really need milliseconds
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