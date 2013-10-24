//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "BaseCoordinator.h"
#import "RequestBuilder.h"
#import "Reauthenticator.h"

@implementation BaseCoordinator {
@private
    NSURLConnection *activeConnection;
    NSURLResponse *activeResponse;
    NSMutableData *activeData;
    NSURLRequest *_activeURLRequest;
    RequestBuilder *_activeRequestBuilder;
}

@synthesize activeURLRequest = _activeURLRequest;
@synthesize activeRequestBuilder = _activeRequestBuilder;

- (BOOL)generateWork {
    return NO;
}

- (BOOL)processResults:(NSData *)data {
    [self setActiveURLRequest:nil];
    [self markComplete];
    return YES;
}

- (BOOL)makeRequest {
    if (![self activeURLRequest]) {
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
    //  TODO
}

- (void)markComplete {
    //  TODO
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