//
//  EEYEOIdObject.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EEYEOIdObject : NSManagedObject

@property(nonatomic, retain) NSString *id;
@property(nonatomic) int64_t modificationTimestamp;

- (NSDate *)modificationTSAsNSDate;

- (void)setModificationTSAsNSDate:(NSDate *)dateTime;

+ (NSDate *)fromJodaDateTime:(long long)jodaDateTimeInMilliseconds;

+ (long long)toJodaDateTime:(NSDate *)dateTime;

@end
