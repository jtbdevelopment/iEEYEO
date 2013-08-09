//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "ClassListsViewController.h"
#import "EEYEOLocalDataStore.h"


@implementation ClassListsViewController {

}
- (NSString *)name {
    return @"Classes";
}

- (NSArray *)sortDescriptors {
    NSSortDescriptor *sortDescriptorN = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptorN];
    return sortDescriptors;
}

- (NSString * const)entityType {
    return CLASSLISTENTITY;
}
@end