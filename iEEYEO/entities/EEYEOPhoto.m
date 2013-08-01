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

- (void)setImageFromImage:(UIImage *)image {
    [self setImageData:UIImageJPEGRepresentation(image, 1.0)];
    //  TODO
    [self setMimeType:@"image/jpeg"];
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
    //  TODO - scale
    [self setThumbnailImageFromData:[self imageData]];
}

- (void)setThumbnailImageFromData:(NSData *)data {
    [self setThumbnailImageData:data];
    _thumbnail = nil;
}

- (BOOL)loadFromDictionary:(NSDictionary *)dictionary {
    [self setMimeType:[dictionary objectForKey:JSON_MIMETYPE]];
    [self setName:[dictionary objectForKey:JSON_DESCRIPTION]];
    [self setTimestamp:[[self fromJodaLocalDateTime:[dictionary objectForKey:JSON_TIMESTAMP]] timeIntervalSince1970]];
    EEYEOAppUserOwnedObject *photoFor = [[EEYEOLocalDataStore instance] find:APPUSEROWNEDENTITY withId:[[dictionary valueForKey:JSON_PHOTOFOR] valueForKey:JSON_ID]];
    if (photoFor) {
        [self setPhotoFor:photoFor];
    } else {
        return NO;
    }
    [self setImageFromData:[NSData dataFromBase64String:[dictionary objectForKey:JSON_IMAGEDATA]]];
    [self setThumbnailImageFromData:[NSData dataFromBase64String:[dictionary objectForKey:@"thumbnailImageData"]]];

    return [super loadFromDictionary:dictionary];
}

- (void)writeToDictionary:(NSMutableDictionary *)dictionary {
    [super writeToDictionary:dictionary];
    [dictionary setObject:[self mimeType] forKey:JSON_MIMETYPE];
    [self writeSubobject:[self photoFor] ToDictionary:dictionary WithKey:JSON_PHOTOFOR];
    [dictionary setObject:[self toJodaLocalDateTime:[self timestampToNSDate]] forKey:JSON_TIMESTAMP];
    [dictionary setObject:[self name] forKey:JSON_DESCRIPTION];
    [dictionary setObject:[[self imageData] base64EncodedStringWithSeparateLines:0] forKey:JSON_IMAGEDATA];
}

@end
