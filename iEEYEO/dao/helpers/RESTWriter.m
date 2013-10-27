//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "RESTWriter.h"
#import "EEYEOIdObject.h"
#import "EEYEORemoteDataStore.h"
#import "EEYEODeletedObject.h"
#import "BaseRESTDelegate.h"
#import "EntityToDictionaryHelper.h"


@implementation RESTWriter {
@private
    EEYEORemoteDataStore *_instance;
}

- (id)initWithRemoteStore:(EEYEORemoteDataStore *)instance {
    self = [super init];
    if (self) {
        _instance = instance;
    }
    return self;
}


- (void)saveEntityToRemote:(EEYEOIdObject *)object {
    if ([object isKindOfClass:[EEYEODeletedObject class]]) {
        return [self deleteEntityToRemote:(EEYEODeletedObject *) object];
    }
    if ([[object id] isEqualToString:@""]) {
        return [self createEntityToRemote:object];
    }
    return [self updateEntityToRemote:object];
}

- (void)updateEntityToRemote:(EEYEOIdObject *)updated {
    NSURLRequest *request = [self createWriteRequestToRemoteServer:updated method:@"PUT" urlString:[_instance entityURLForObject:updated]];
    //[_instance addWorkItem:[[BaseRESTDelegate alloc] initWithRequest:request]];
}

- (void)createEntityToRemote:(EEYEOIdObject *)created {
    NSMutableURLRequest *request = [self createWriteRequestToRemoteServer:created method:@"POST" urlString:[_instance userURL]];
    //[_instance addWorkItem:[[CreationRESTDelegate alloc] initWithRequest:request AndEntity:created AndWriter:self]];
}

- (void)deleteEntityToRemote:(EEYEODeletedObject *)deleted {
    NSURL *url = [[NSURL alloc] initWithString:[_instance entityURLForId:[deleted deletedId]]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"DELETE"];

    //[_instance addWorkItem:[[DeletionRESTDelegate alloc] initWithDeletedObject:deleted AndRequest:request]];
}

- (NSMutableURLRequest *)createWriteRequestToRemoteServer:(EEYEOIdObject *)entity method:(NSString *)method urlString:(NSString *)urlString {
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:method];

    [EntityToDictionaryHelper writeEntity:entity ToForm:request];
    return request;
}


@end