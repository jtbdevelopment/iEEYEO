//
//  EEYEOAppUser.h
//  iEEYEO
//
//  Copyright (c) 2013 jtbdevelopment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EEYEOIdObject.h"


@interface EEYEOAppUser : EEYEOIdObject

@property(nonatomic) BOOL activated;
@property(nonatomic) BOOL active;
@property(nonatomic) BOOL admin;
@property(nonatomic, retain) NSString *emailAddress;
@property(nonatomic, retain) NSString *firstName;
@property(nonatomic) int64_t lastLogout;
@property(nonatomic, retain) NSString *lastName;

@end
