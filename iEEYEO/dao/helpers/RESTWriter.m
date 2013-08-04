//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "RESTWriter.h"
#import "EEYEOIdObject.h"
#import "EEYEORemoteDataStore.h"
#import "EEYEODeletedObject.h"
#import "BaseRESTDelegate.h"
#import "CreationRESTDelegate.h"
#import "DeletionRESTDelegate.h"


@implementation RESTWriter {
@private
    EEYEORemoteDataStore *_instance;
}

- (id)initForRemoteStore:(EEYEORemoteDataStore *)instance {
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
    [_instance addWorkItem:[[BaseRESTDelegate alloc] initWithRequest:request]];
}

- (void)createEntityToRemote:(EEYEOIdObject *)created {
    NSMutableURLRequest *request = [self createWriteRequestToRemoteServer:created method:@"POST" urlString:[_instance userURL]];
    [_instance addWorkItem:[[CreationRESTDelegate alloc] initWithRequest:request AndEntity:created AndWriter:self]];
}

- (void)deleteEntityToRemote:(EEYEODeletedObject *)deleted {
    NSURL *url = [[NSURL alloc] initWithString:[_instance entityURLForId:[deleted deletedId]]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"DELETE"];

    [_instance addWorkItem:[[DeletionRESTDelegate alloc] initWithDeletedObject:deleted AndRequest:request]];
}

- (NSMutableURLRequest *)createWriteRequestToRemoteServer:(EEYEOIdObject *)entity method:(NSString *)method urlString:(NSString *)urlString {
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:method];

    [self writeDictionaryAsForm:request dictionary:[self getDictionary:entity] forEntity:entity];
    return request;
}

- (void)writeDictionaryAsForm:(NSMutableURLRequest *)request dictionary:(NSMutableDictionary *)dictionary forEntity:(EEYEOIdObject *)entity {
    NSError *error;
    NSOutputStream *stream = [[NSOutputStream alloc] initToMemory];
    [stream open];
    [NSJSONSerialization writeJSONObject:dictionary toStream:stream options:NSJSONWritingPrettyPrinted error:&error];
    [stream close];
    NSData *streamData = [stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    NSString *form = [[NSString alloc] initWithFormat:@"appUserOwnedObject=%@", [[NSString alloc] initWithData:streamData encoding:NSASCIIStringEncoding]];

    //  TODO - hack to do with JSON parser requiring entity type being first field
    NSString *replacement = [[NSString alloc] initWithFormat:@"appUserOwnedObject={ \"entityType\": \"%@\",", [[EEYEORemoteDataStore iosToJavaEntityMap] valueForKey:[[entity class] description]]];
    form = [form stringByReplacingOccurrencesOfString:@"appUserOwnedObject={" withString:replacement];

    char const *bytes = [form UTF8String];
    [request setHTTPBody:[NSData dataWithBytes:bytes length:[form length]]];
}

- (NSMutableDictionary *)getDictionary:(EEYEOIdObject *)entity {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [entity writeToDictionary:dictionary];
    return dictionary;
}

@end