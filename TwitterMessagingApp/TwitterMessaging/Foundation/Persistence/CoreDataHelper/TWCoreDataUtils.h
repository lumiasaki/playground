//
//  TWCoreDataOperations.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/5.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface TWCoreDataUtils : NSObject

+ (NSManagedObject *)insertManagedObjectFor:(NSString *)entityName;
+ (NSArray<NSManagedObject *> *)selectIn:(NSString *)entityName predicate:(NSPredicate *)predicate;
+ (void)deleteManagedObject:(NSManagedObject *)managedObject inEntity:(NSString *)entityName;
+ (void)saveContext:(NSError *)error;

@end
