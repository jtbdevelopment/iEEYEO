//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>


@interface ThumbnailImageCell : UICollectionViewCell

@property(strong, nonatomic) UIImageView *image;
@property(strong, nonatomic) UILabel *label;

- (void)setImage:(UIImage *)image;
@end