//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>


@interface StudentsViewLayout : UICollectionViewFlowLayout {
    UICollectionViewScrollDirection scrollDirection;
}
@property(nonatomic) UICollectionViewScrollDirection scrollDirection;

- (UICollectionViewScrollDirection)scrollDirection;

@end