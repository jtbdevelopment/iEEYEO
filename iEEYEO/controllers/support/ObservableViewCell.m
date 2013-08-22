//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <QuartzCore/QuartzCore.h>
#import "ObservableViewCell.h"
#import "Colors.h"
#import "EEYEOObservable.h"
#import "EEYEOClassList.h"
#import "EEYEOStudent.h"


@implementation ObservableViewCell {
@private
    UILabel *label;
}

- (void)setObservable:(EEYEOObservable *)observable {
    label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    if ([observable isKindOfClass:[EEYEOClassList class]]) {
        label.text = [(EEYEOClassList *) observable desc];
    } else if ([observable isKindOfClass:[EEYEOStudent class]]) {
        label.text = [[(EEYEOStudent *) observable firstName] stringByAppendingFormat:@"\r%@", [(EEYEOStudent *) observable lastName]];
    } else {
        label.text = @"Unknown!";
    }
    [self.contentView addSubview:label];
    label.layer.cornerRadius = 10.0;
    label.numberOfLines = 2;
    [label setBackgroundColor:[Colors darkBrown]];
}

@end