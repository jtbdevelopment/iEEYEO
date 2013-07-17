//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import <Foundation/Foundation.h>

@class EEYEOObservable;


@interface ObservableViewCell : UICollectionViewCell

@property(nonatomic, strong) EEYEOObservable *observable;

- (void)setObservable:(EEYEOObservable *)observable;
@end