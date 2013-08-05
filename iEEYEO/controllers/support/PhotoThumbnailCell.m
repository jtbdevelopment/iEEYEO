//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "PhotoThumbnailCell.h"
#import "Colors.h"


@implementation PhotoThumbnailCell {

@private
    UIImageView *_imageView;
    UILabel *_label;
}
@synthesize imageView = _imageView;
@synthesize label = _label;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }

    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if ([self isHighlighted]) {
        [self setBackgroundColor:[Colors forestGreen]];
    } else {
        [self setBackgroundColor:[UIColor clearColor]];
    }

}


@end