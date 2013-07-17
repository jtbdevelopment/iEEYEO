//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>


@interface ObservablesViewLayout : UICollectionViewFlowLayout {
    UICollectionViewScrollDirection scrollDirection;
}
@property(nonatomic) UICollectionViewScrollDirection scrollDirection;

- (UICollectionViewScrollDirection)scrollDirection;

@end