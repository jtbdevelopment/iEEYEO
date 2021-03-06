//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "EntityRelatedRequest.h"
#import "EEYEOIdObject.h"
#import "EntityToDictionaryHelper.h"
#import "EEYEOLocalDataStore.h"


@implementation EntityRelatedRequest {
@private
    EEYEOIdObject *_entity;
}
@synthesize entity = _entity;

- (id)initForEntity:(EEYEOIdObject *)entity {
    self = [super init];
    if (self) {
        [self setEntity:entity];
    }
    return self;

}

- (NSString *)restEntityIdURL:(NSString *)id {
    return [[self restUserURL] stringByAppendingFormat:@"%@/", id];

}

- (NSURLRequest *)createRequestToServer:(EEYEOIdObject *)entity method:(NSString *)method urlString:(NSString *)urlString {
    //  If there are multiple requests queued, related ids may not have initially been available
    //  Refresh from DB before sending
    //
    //  TODO - deal with changes/deletes in interim
    //
    [[EEYEOLocalDataStore instance] refreshObject:[self entity]];

    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:method];

    [EntityToDictionaryHelper writeEntity:entity ToForm:request];
    return request;
}

@end