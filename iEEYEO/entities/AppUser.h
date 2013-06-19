//
//


#import <Foundation/Foundation.h>
#import "IdObject.h"


@interface AppUser : IdObject
@property(nonatomic, copy) NSString *firstName;
@property(nonatomic, copy) NSString *lastName;
@property(nonatomic, copy) NSString *emailAddress;
//  TODO - determine if we need password here
@property(nonatomic, copy) NSString *password;
@property(nonatomic) NSUInteger lastLogout;
@property(nonatomic) BOOL activated;
@property(nonatomic) BOOL active;
@property(nonatomic) BOOL admin;
@end
