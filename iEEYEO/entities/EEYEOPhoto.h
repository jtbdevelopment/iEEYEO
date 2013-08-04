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

static NSString *const JSON_MIMETYPE = @"mimeType";

static NSString *const JSON_PHOTOFOR = @"photoFor";

static NSString *const JSON_TIMESTAMP = @"timestamp";

static NSString *const JSON_IMAGEDATA = @"imageData";

static NSString *const JSON_THUMBNAILIMAGEDATE = @"thumbnailImageData";

@interface EEYEOPhoto : EEYEOAppUserOwnedObject

@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSData *imageData;
@property(nonatomic, retain) NSString *mimeType;
@property(nonatomic, retain) NSData *thumbnailImageData;
@property(nonatomic) NSTimeInterval timestamp;
@property(nonatomic, retain) EEYEOAppUserOwnedObject *photoFor;

- (UIImage *)image;

- (void)setImageFromImage:(UIImage *)image;

- (void)setImageFromData:(NSData *)data;

- (void)setThumbnailImageFromData:(NSData *)data;

- (UIImage *)thumbnailImage;

- (NSDate *)timestampToNSDate;

- (void)setTimestampFromNSDate:(NSDate *)date;

@end
