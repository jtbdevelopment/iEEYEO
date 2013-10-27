//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "RequestCoordinator.h"
#import "RequestBuilder.h"
#import "Reauthenticator.h"
#import "EEYEORemoteQueue.h"
#import "EEYEOLocalDataStore.h"

@implementation RequestCoordinator {
@private
    NSURLConnection *activeConnection;
    NSURLResponse *activeResponse;
    NSMutableData *activeData;
    NSURLRequest *_activeURLRequest;
    RequestBuilder *_activeRequestBuilder;
    NSUInteger _attempts;
}

@synthesize activeURLRequest = _activeURLRequest;
@synthesize activeRequestBuilder = _activeRequestBuilder;

@synthesize attempts = _attempts;

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return YES;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    //  TODO - Unclear if this works or even necessary
    NSURLCredential *credential = [NSURLCredential credentialWithUser:[[EEYEOLocalDataStore instance] login]
                                                             password:[[EEYEOLocalDataStore instance] password]
                                                          persistence:NSURLCredentialPersistencePermanent];
    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}

- (id)init {
    self = [super init];
    if (self) {
        [self setAttempts:0];
    }

    return self;
}


- (BOOL)doWork {
    if ([self activeURLRequest] || [self activeRequestBuilder]) {
        return [self makeRequest];
    }

    RequestBuilder *requestBuilder = [self generateRequestBuilder];
    if (requestBuilder) {
        [self setActiveRequestBuilder:requestBuilder];
        return [self makeRequest];
    } else {
        [self markComplete];
    }

    return NO;
}

- (RequestBuilder *)generateRequestBuilder {
    return nil;
}

- (BOOL)processResults:(NSData *)data {
    [self setActiveURLRequest:nil];
    [self setActiveRequestBuilder:nil];
    [self markComplete];
    return YES;
}

- (BOOL)makeRequest {
    if (![self activeURLRequest]) {
        if (![self activeRequestBuilder]) {
            return NO;
        }
        [self setActiveURLRequest:[[self activeRequestBuilder] createNSURLRequest]];
    }
    activeConnection = [[NSURLConnection alloc] initWithRequest:[self activeURLRequest] delegate:self];
    if (!activeConnection) {
        [self requeueSelf];
        return NO;
    }
    return YES;
}

- (void)requeueSelf {
    [[EEYEORemoteQueue instance] resubmitRequest:self];
}

- (void)markComplete {
    [[EEYEORemoteQueue instance] closeRequest:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == activeConnection) {
        activeResponse = response;
        activeData = [[NSMutableData alloc] init];
        [activeData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == activeConnection) {
        [activeData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (activeConnection != connection) {
        return;
    }
    if ([[activeResponse MIMEType] isEqualToString:@"text/html"]) {
        [self reauthenticateAndRetry];
    } else {
        if ([activeResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) activeResponse;
            if ([httpResponse statusCode] == 201) {
                NSString *location = [[httpResponse allHeaderFields] valueForKey:@"Location"];
                NSURL *newURL = [[NSURL alloc] initWithString:location];
                [self setActiveURLRequest:[[NSURLRequest alloc] initWithURL:newURL]];
                [self makeRequest];
                return;
            }
        }
        if (![self processResults:activeData]) {
            [self requeueSelf];
        }
    }
}

- (id)convertToJSON:(NSData *)data {
    NSError *error;
    id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error) {
        return nil;
    }
    return json;
}

- (void)reauthenticateAndRetry {
    NSString *html = [[NSString alloc] initWithData:activeData encoding:NSUTF8StringEncoding];
    if ([html rangeOfString:@"javascript"].location == NSNotFound) {
        [self requeueSelf];
    } else {
        if ([Reauthenticator reauthenticate]) {
            [self makeRequest];
        } else {
            [self requeueSelf];
        }
    }
}

@end