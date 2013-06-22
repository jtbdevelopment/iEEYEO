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

@end
