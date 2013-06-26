//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "Colors.h"


@implementation Colors {

}
+ (UIColor *)cream {
    static UIColor *CREAM = nil;
    if (!CREAM) {
        CREAM = [UIColor colorWithRed:0.949 green:0.89 blue:0.725 alpha:1]; /*#f2e3b9*/
    }
    return CREAM;
}

+ (UIColor *)darkBrown {
    static UIColor *DARK_BROWN = nil;
    if (!DARK_BROWN) {
        DARK_BROWN = [UIColor colorWithRed:0.773 green:0.451 blue:0.294 alpha:1]; /*#c5734b*/
    }
    return DARK_BROWN;
}

+ (UIColor *)forestGreen {
    static UIColor *FOREST_GREEN = nil;
    if (!FOREST_GREEN) {
        FOREST_GREEN = [UIColor colorWithRed:0.8 green:0.765 blue:0.502 alpha:1];/*#ccc380*/
    }
    return FOREST_GREEN;
}

@end