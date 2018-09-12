//
//  TWCoreDataOperations.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/5.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWCoreDataUtils.h"
#import <UIKit/UIKit.h>
#import "TWUtils.h"
#import "TWCoreDataStack.h"

@implementation TWCoreDataUtils

+ (NSManagedObject *)insertManagedObjectFor:(NSString *)entityName {
    if ([TWUtils stringIsEmpty:entityName]) {
        return nil;
    }
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.context];
    return [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.context];
}

+ (NSArray<NSManagedObject *> *)selectIn:(NSString *)entityName predicate:(NSPredicate *)predicate {
    if ([TWUtils stringIsEmpty:entityName]) {
        return nil;
    }
    
    NSFetchRequest *fetchResult = [NSFetchRequest fetchRequestWithEntityName:entityName];
    fetchResult.predicate = predicate;
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchResult error:&error];
    if (!error) {
        return result;
    }
    return nil;
}

+ (void)deleteManagedObject:(NSManagedObject *)managedObject inEntity:(NSString *)entityName; {
    if ([TWUtils stringIsEmpty:entityName] || ![managedObject isKindOfClass:NSManagedObject.class]) {
        return;
    }
    
    [self.context deleteObject:managedObject];
}

+ (void)saveContext:(NSError *)error {
    NSManagedObjectContext *context = self.context;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

#pragma mark - private

+ (NSManagedObjectContext *)context {
    return TWCoreDataStack.sharedCoreDataStack.context;
}

@end
