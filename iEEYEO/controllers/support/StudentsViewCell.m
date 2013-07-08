//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "StudentsViewCell.h"
#import "Colors.h"


@implementation StudentsViewCell {

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat halfHeight = frame.size.height / 2;
        self.first = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, halfHeight)];
        self.first.textAlignment = NSTextAlignmentCenter;
        self.first.textColor = [UIColor blackColor];
        self.first.font = [UIFont boldSystemFontOfSize:20.0];

        self.last = [[UILabel alloc] initWithFrame:CGRectMake(0.0, halfHeight, frame.size.width, halfHeight)];
        self.last.textAlignment = NSTextAlignmentCenter;
        self.last.textColor = [UIColor blackColor];
        self.last.font = [UIFont boldSystemFontOfSize:20.0];

        [self setHighlighted:NO];

        [self.contentView addSubview:self.first];
        [self.contentView addSubview:self.last];

        [self.contentView setBackgroundColor:[UIColor blueColor]];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    UIColor *color;
    if (highlighted) {
        color = [Colors forestGreen];
    } else {
        color = [Colors darkBrown];
    }
    [self.first setBackgroundColor:color];
    [self.last setBackgroundColor:color];
}

@end