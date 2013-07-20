//
//  EEYEOAppDelegate.h
//  iEEYEO
//
//

#import <UIKit/UIKit.h>

@interface EEYEOAppDelegate : UIResponder <UIApplicationDelegate>

@property(strong, nonatomic) UIWindow *window;

@property(readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property(readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)remoteSync;

- (void)saveContext;

- (NSURL *)applicationDocumentsDirectory;

@end