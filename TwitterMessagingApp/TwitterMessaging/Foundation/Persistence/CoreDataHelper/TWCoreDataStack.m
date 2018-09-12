//
//  TWCoreDataStack.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/5.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWCoreDataStack.h"

@interface TWCoreDataStack ()

@property (nonatomic, strong) NSManagedObjectContext *managedContext;
@property (nonatomic, strong) NSPersistentContainer *persistentContainer;

@end
@implementation TWCoreDataStack

@synthesize persistentContainer = _persistentContainer;

+ (instancetype)sharedCoreDataStack {
    static TWCoreDataStack *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TWCoreDataStack alloc] init];
    });
    return instance;
}

- (NSManagedObjectContext *)context {
    if (!_managedContext) {
        _managedContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _managedContext.persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator;
    }
    return _managedContext;
}

#pragma mark - private

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"TwitterMessaging"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

@end
