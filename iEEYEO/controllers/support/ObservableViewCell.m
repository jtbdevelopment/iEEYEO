//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "ObservableViewCell.h"
#import "Colors.h"
#import "EEYEOObservable.h"
#import "EEYEOClassList.h"
#import "EEYEOStudent.h"


@implementation ObservableViewCell {
@private
    UILabel *top;
    UILabel *bottom;
}

- (void)setObservable:(EEYEOObservable *)observable {
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    CGFloat halfHeight = height / 2;
    NSString *topText;
    NSString *bottomText;
    if ([observable isKindOfClass:[EEYEOClassList class]]) {

        topText = [(EEYEOClassList *) observable desc];
        bottomText = @"";
    } else if ([observable isKindOfClass:[EEYEOStudent class]]) {
        topText = [(EEYEOStudent *) observable firstName];
        bottomText = [(EEYEOStudent *) observable lastName];
    } else {
        topText = @"Unknown!";
        bottomText = @"";
    }
    if ([bottomText isEqualToString:@""]) {
        top = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width, height)];
        top.textAlignment = NSTextAlignmentCenter;
        top.textColor = [UIColor blackColor];
        top.font = [UIFont boldSystemFontOfSize:20.0];
        top.text = topText;
        bottom = nil;
        [self.contentView addSubview:top];
    } else {
        top = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width, halfHeight)];
        top.textAlignment = NSTextAlignmentCenter;
        top.textColor = [UIColor blackColor];
        top.font = [UIFont boldSystemFontOfSize:20.0];
        top.text = topText;

        bottom = [[UILabel alloc] initWithFrame:CGRectMake(0.0, halfHeight, width, halfHeight)];
        bottom.textAlignment = NSTextAlignmentCenter;
        bottom.textColor = [UIColor blackColor];
        bottom.font = [UIFont boldSystemFontOfSize:20.0];
        bottom.text = bottomText;
        [self.contentView addSubview:top];
        [self.contentView addSubview:bottom];
    }

    [self setHighlighted:NO];

}

- (void)setHighlighted:(BOOL)highlighted {
    UIColor *color;
    if (highlighted) {
        color = [Colors forestGreen];
    } else {
        color = [Colors darkBrown];
    }
    [top setBackgroundColor:color];
    if (bottom) {
        [bottom setBackgroundColor:color];
    }
}

@end