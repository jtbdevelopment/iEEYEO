//
//  EEYEOPhoto.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EEYEOAppUserOwnedObject.h"

@class EEYEOAppUserOwnedObject;

@interface EEYEOPhoto : EEYEOAppUserOwnedObject

@property(nonatomic, retain) NSString *desc;
@property(nonatomic, retain) NSData *imageData;
@property(nonatomic, retain) NSString *mimeType;
@property(nonatomic, retain) NSData *thumbnailImageData;
@property(nonatomic) NSTimeInterval timestamp;
@property(nonatomic, retain) EEYEOAppUserOwnedObject *photoFor;

@end
