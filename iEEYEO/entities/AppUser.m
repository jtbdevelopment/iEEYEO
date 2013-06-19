//
// Copyright (c) 2013 jtbdevelopment. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "AppUser.h"


@implementation AppUser {

@private
    NSString *_firstName;
    NSString *_lastName;
    NSString *_emailAddress;
    NSString *_password;
    NSUInteger _lastLogout;
    BOOL _activated;
    BOOL _active;
    BOOL _admin;
}
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize emailAddress = _emailAddress;
@synthesize password = _password;
@synthesize lastLogout = _lastLogout;
@synthesize activated = _activated;
@synthesize active = _active;
@synthesize admin = _admin;
@end