//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "StudentsViewCell.h"


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
        self.first.backgroundColor = [UIColor whiteColor];

        self.last = [[UILabel alloc] initWithFrame:CGRectMake(0.0, halfHeight, frame.size.width, halfHeight)];
        self.last.textAlignment = NSTextAlignmentCenter;
        self.last.textColor = [UIColor blackColor];
        self.last.font = [UIFont boldSystemFontOfSize:20.0];
        self.last.backgroundColor = [UIColor whiteColor];

        [self.contentView addSubview:self.first];
        [self.contentView addSubview:self.last];

        [self.contentView setBackgroundColor:[UIColor blueColor]];
    }
    return self;
}
@end