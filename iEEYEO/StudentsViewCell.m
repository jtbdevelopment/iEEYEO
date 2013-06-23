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
    //  TODO - central colors

    if (highlighted) {
        UIColor *FOREST_GREEN = [UIColor colorWithRed:0.8 green:0.765 blue:0.502 alpha:1]; /*#ccc380*/
        self.first.backgroundColor = FOREST_GREEN;
        [self.last setBackgroundColor:FOREST_GREEN];
    } else {
        UIColor *CREAM = [UIColor colorWithRed:0.949 green:0.89 blue:0.725 alpha:1]; /*#f2e3b9*/
        self.first.backgroundColor = CREAM;
        [self.last setBackgroundColor:CREAM];
    }
}

@end