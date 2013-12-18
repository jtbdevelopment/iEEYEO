//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "EEYEOIdObject.h"
#import "EntityToDictionaryHelper.h"


@implementation EntityToDictionaryHelper

+ (void)writeEntity:(EEYEOIdObject *)entity ToForm:(NSMutableURLRequest *)request {
    [EntityToDictionaryHelper writeDictionary:[EntityToDictionaryHelper getDictionary:entity] ToForm:request];
}

+ (void)writeDictionary:(NSMutableDictionary *)dictionary ToForm:(NSMutableURLRequest *)request {
    NSError *error;
    NSOutputStream *stream = [[NSOutputStream alloc] initToMemory];
    [stream open];
    [NSJSONSerialization writeJSONObject:dictionary toStream:stream options:NSJSONWritingPrettyPrinted error:&error];
    [stream close];
    NSData *streamData = [stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    NSString *form = [[NSString alloc] initWithFormat:@"appUserOwnedObject=%@", [[NSString alloc] initWithData:streamData encoding:NSASCIIStringEncoding]];

    char const *bytes = [form UTF8String];
    [request setHTTPBody:[NSData dataWithBytes:bytes length:[form length]]];
}

+ (NSMutableDictionary *)getDictionary:(EEYEOIdObject *)entity {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [entity writeToDictionary:dictionary];
    return dictionary;
}

@end