//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>


@interface IdObject : NSObject

@property(nonatomic, copy) NSString *id;
@property(nonatomic) NSUInteger modificationTimestamp;

- (id)initWithId:(NSString *)id modificationTimestamp:(NSUInteger)modificationTimestamp;

- (NSString *)description;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToObject:(IdObject *)object;

- (NSUInteger)hash;

+ (id)objectWithId:(NSString *)id modificationTimestamp:(NSUInteger)modificationTimestamp;


@end