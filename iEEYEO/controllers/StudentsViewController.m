//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
//


#import "StudentsViewController.h"
#import "EEYEOLocalDataStore.h"


@implementation StudentsViewController {

}
- (NSArray *)sortDescriptors {
    NSSortDescriptor *sortDescriptorFN = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *sortDescriptorLN = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptorFN, sortDescriptorLN];
    return sortDescriptors;
}

- (NSString * const)entityType {
    return STUDENTENTITY;
}
@end