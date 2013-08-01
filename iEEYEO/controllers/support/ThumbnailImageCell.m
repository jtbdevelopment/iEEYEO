//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "ThumbnailImageCell.h"


@implementation ThumbnailImageCell {
@private
    UIImageView *imageView;
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat height = self.frame.size.height;
        CGFloat width = self.frame.size.width;
        CGFloat halfHeight = height / 2;
        NSString *topText;
        NSString *bottomText;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, height)];
        [self addSubview:imageView];
    }

    return self;
}

- (void)setImage:(UIImage *)image {

    [imageView setImage:image];
}

@end