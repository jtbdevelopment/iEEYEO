//


#import "IdObject.h"


@implementation IdObject {

@private
    NSString *_id;
    NSUInteger _modificationTimestamp;
}

@synthesize id = _id;
@synthesize modificationTimestamp = _modificationTimestamp;

- (id)init {
    return [self initWithId:(NSString *) @"" modificationTimestamp:(NSUInteger) 0];
}

- (id)initWithId:(NSString *)id modificationTimestamp:(NSUInteger)modificationTimestamp {
    self = [super init];
    if (self) {
        self.id = id;
        self.modificationTimestamp = modificationTimestamp;
    }

    return self;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.id=%@", self.id];
    [description appendFormat:@", self.modificationTimestamp=%u", self.modificationTimestamp];
    [description appendString:@">"];
    return description;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToObject:other];
}

- (BOOL)isEqualToObject:(IdObject *)object {
    if (self == object)
        return YES;
    if (object == nil)
        return NO;
    if (self.id != object.id && ![self.id isEqualToString:object.id])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    return [self.id hash];
}


+ (id)objectWithId:(NSString *)id modificationTimestamp:(NSUInteger)modificationTimestamp {
    return [[self alloc] initWithId:id modificationTimestamp:modificationTimestamp];
}


@end