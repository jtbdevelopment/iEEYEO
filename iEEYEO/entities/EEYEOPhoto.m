//
//  EEYEOPhoto.m
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import "EEYEOPhoto.h"
#import "EEYEOLocalDataStore.h"
#import "NSData+Base64.h"


@implementation EEYEOPhoto {
@private
    UIImage *_image;
    UIImage *_thumbnail;
}

@dynamic name;
@dynamic imageData;
@dynamic mimeType;
@dynamic thumbnailImageData;
@dynamic timestamp;
@dynamic photoFor;

- (UIImage *)image {
    if (!_image) {
        _image = [UIImage imageWithData:[self imageData]];
    }
    return _image;
}

- (NSDate *)timestampToNSDate {
    return [NSDate dateWithTimeIntervalSince1970:[self timestamp]];
}

- (void)setTimestampFromNSDate:(NSDate *)date {
    [self setTimestamp:[date timeIntervalSince1970]];
}

- (UIImage *)resizeImage:(UIImage *)inImage withMaxEdge:(int)maxEdge {
    CGFloat originalHeight = inImage.size.height;
    CGFloat originalWidth = inImage.size.width;
    CGFloat newHeight;
    CGFloat newWidth;
    if (originalHeight > originalWidth) {
        if (originalHeight <= maxEdge) {
            return inImage;
        }
        newHeight = maxEdge;
        newWidth = (newHeight / originalHeight) * originalWidth;
    } else {
        if (originalWidth <= maxEdge) {
            return inImage;
        }
        newWidth = maxEdge;
        newHeight = (newWidth / originalWidth) * originalHeight;
    }

    CGRect rect = CGRectMake(0.0, 0.0, newWidth, newHeight);
    UIGraphicsBeginImageContext(rect.size);
    [inImage drawInRect:rect];
    UIImage *outImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outImage;
}

- (void)setImageFromImage:(UIImage *)image {
    static int MAX_THUMBNAIL_SIZE = 150;
    static int MAX_IMAGE_SIZE = 1024;
    [self setImageData:UIImageJPEGRepresentation([self resizeImage:image withMaxEdge:MAX_IMAGE_SIZE], 0.5)];
    [self setMimeType:@"image/png"];
    [self setThumbnailImageFromData:UIImageJPEGRepresentation([self resizeImage:image withMaxEdge:MAX_THUMBNAIL_SIZE], 1.0)];
}

- (UIImage *)thumbnailImage {
    if (!_thumbnail) {
        _thumbnail = [UIImage imageWithData:[self thumbnailImageData]];
    }
    return _thumbnail;
}

- (void)setImageFromData:(NSData *)data {
    [self setImageData:data];
    _image = nil;
}

- (void)setThumbnailImageFromData:(NSData *)data {
    [self setThumbnailImageData:data];
    _thumbnail = nil;
}

- (BOOL)loadFromDictionary:(NSDictionary *)dictionary {
    [self setMimeType:[dictionary objectForKey:JSON_MIMETYPE]];
    [self setName:[dictionary objectForKey:JSON_DESCRIPTION]];
    [self setTimestamp:[[EEYEOIdObject fromJodaLocalDateTime:[dictionary objectForKey:JSON_TIMESTAMP]] timeIntervalSince1970]];
    EEYEOAppUserOwnedObject *photoFor = [[EEYEOLocalDataStore instance] find:APPUSEROWNEDENTITY withId:[[dictionary valueForKey:JSON_PHOTOFOR] valueForKey:JSON_ID]];
    if (photoFor) {
        [self setPhotoFor:photoFor];
    } else {
        return NO;
    }
    [self setImageFromData:[NSData dataFromBase64String:[dictionary objectForKey:JSON_IMAGEDATA]]];
    [self setThumbnailImageFromData:[NSData dataFromBase64String:[dictionary objectForKey:JSON_THUMBNAILIMAGEDATE]]];

    return [super loadFromDictionary:dictionary];
}

- (void)writeToDictionary:(NSMutableDictionary *)dictionary {
    [super writeToDictionary:dictionary];
    [dictionary setObject:[self mimeType] forKey:JSON_MIMETYPE];
    [self writeSubobject:[self photoFor] ToDictionary:dictionary WithKey:JSON_PHOTOFOR];
    [dictionary setObject:[EEYEOIdObject toJodaLocalDateTime:[self timestampToNSDate]] forKey:JSON_TIMESTAMP];
    [dictionary setObject:[self name] forKey:JSON_DESCRIPTION];

    [dictionary setObject:[[self imageData] base64EncodedStringWithSeparateLines:NO] forKey:JSON_IMAGEDATA];
}

@end
