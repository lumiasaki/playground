//
//  TWPersistingModule.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/5.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWPersistingManager.h"
#import <CoreData/CoreData.h>
#import <objc/runtime.h>
#import <objc/objc.h>
#import "TWBaseModel.h"
#import "TWCoreDataUtils.h"

#define ASSERT_EXECUTE_ON_PERSISTING_QUEUE() NSAssert(TWIsPersistingWorkQueue(), @"%@ should be invoked on persisting queue", NSStringFromSelector(_cmd));

@implementation TWPersistingManager

+ (instancetype)sharedManager {
    static TWPersistingManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TWPersistingManager alloc] init];
    });
    return instance;
}

- (void)insertObject:(TWBaseModel *)object {
    TWExecuteOnPersistingQueue(^{
        NSManagedObject *managedObject = [TWCoreDataUtils insertManagedObjectFor:entityNameFrom(object.class)];
        if (!managedObject) {
            return;
        }
        
        [self fillManagedObjectFromModel:managedObject model:object];
    }, YES);
}

- (NSSet<TWBaseModel *> *)selectObjects:(Class)objectClass predicate:(NSPredicate *)predicate {
    NSMutableSet *objects = [[NSMutableSet alloc] init];
    TWExecuteOnPersistingQueue(^{
        NSArray<NSManagedObject *> *managedObjects = [TWCoreDataUtils selectIn:entityNameFrom(objectClass) predicate:predicate];
        for (NSManagedObject *managedObject in managedObjects) {
            TWBaseModel *model = [self fillModelFromManagedObject:managedObject modelClass:objectClass];
            if (model) {
                [objects addObject:model];
            }
        }
    }, YES);
    
    return objects.copy;
}

- (void)updateObject:(TWBaseModel *)object {
    TWExecuteOnPersistingQueue(^{
        NSManagedObject *managedObject = [self associatedManagedObjectFrom:object];
        if (managedObject) {
            [self fillManagedObjectFromModel:managedObject model:object];
        }
    }, YES);
}

- (void)deleteObject:(TWBaseModel *)object {
    TWExecuteOnPersistingQueue(^{
        NSManagedObject *managedObject = [self associatedManagedObjectFrom:object];
        if (managedObject) {
            [TWCoreDataUtils deleteManagedObject:managedObject inEntity:entityNameFrom(object.class)];
        }
    }, YES);
}

- (void)save {
    TWExecuteOnPersistingQueue(^{
        @try {
            NSError *error;
            [TWCoreDataUtils saveContext:error];
        }
        @catch (NSException *e) {
            NSLog(@"%@", e.description);
        }
    }, NO);
}

#pragma mark - private

- (NSManagedObject *)associatedManagedObjectFrom:(TWBaseModel *)model {
    NSManagedObject *managedObject = nil;
    NSArray<NSManagedObject *> *selectResult = [TWCoreDataUtils selectIn:entityNameFrom(model.class) predicate:[NSPredicate predicateWithFormat:@"modelUniqueId = %@", model.modelUniqueId]];
    
    if (selectResult.count == 1) {
        managedObject = selectResult[0];
    }
    
    return managedObject;
}

#pragma mark - utils

- (void)fillManagedObjectFromModel:(NSManagedObject *)managedObject model:(TWBaseModel *)model {
    if (![managedObject valueForKey:@"modelUniqueId"]) {
        [managedObject setValue:model.modelUniqueId forKey:@"modelUniqueId"];
    }
    
    NSMutableArray<NSDictionary *> *properties = [[NSMutableArray alloc] init];
    propertyListOf(model.class, properties);
    
    for (unsigned int i = 0; i < properties.count; i++) {
        NSDictionary *property = properties[i];
        NSString *propertyName = property[@"propertyName"];
        Class classAssociatedWithProperty = NSClassFromString(property[@"className"]);
        
        if (classAssociatedWithProperty != NULL && [classAssociatedWithProperty isSubclassOfClass:TWBaseModel.class]) {
            TWBaseModel *subModel = [model valueForKey:propertyName];
            NSManagedObject *subManagedObject = [self associatedManagedObjectFrom:subModel];
            if (subManagedObject) {
                (void)[self fillManagedObjectFromModel:subManagedObject model:subModel];
            } else {
                subManagedObject = [TWCoreDataUtils insertManagedObjectFor:entityNameFrom(subModel.class)];
                
                [self fillManagedObjectFromModel:subManagedObject model:subModel];
            }
            [managedObject setValue:subManagedObject forKey:propertyName];
        } else if ([classAssociatedWithProperty isSubclassOfClass:NSSet.class]) {
            NSSet *subModels = [model valueForKey:propertyName];
            
            NSMutableSet *subManagedObjects = [[NSMutableSet alloc] init];
            for (TWBaseModel *subModel in subModels) {
                if ([subModel isKindOfClass:TWBaseModel.class]) {
                    NSManagedObject *subManagedObject = [self associatedManagedObjectFrom:subModel];
                    if (subManagedObject) {
                        (void)[self fillManagedObjectFromModel:subManagedObject model:subModel];
                    } else {
                        subManagedObject = [TWCoreDataUtils insertManagedObjectFor:entityNameFrom(subModel.class)];
                        
                        [self fillManagedObjectFromModel:subManagedObject model:subModel];
                    }
                    [subManagedObjects addObject:subManagedObject];
                }
            }
            [managedObject setValue:subManagedObjects.copy forKey:propertyName];
        } else {
            id value = [model valueForKey:propertyName];
            [managedObject setValue:value forKey:propertyName];
        }
    }
}

- (TWBaseModel *)fillModelFromManagedObject:(NSManagedObject *)managedObject modelClass:(Class)modelClass {
    TWBaseModel *resultModel = [[modelClass alloc] init];
    [resultModel setValue:[managedObject valueForKey:@"modelUniqueId"] forKey:@"modelUniqueId"];
    
    NSMutableArray<NSDictionary *> *properties = [[NSMutableArray alloc] init];
    propertyListOf(modelClass, properties);
    
    for (unsigned int i = 0; i < properties.count; i++) {
        NSDictionary *property = properties[i];
        NSString *propertyName = property[@"propertyName"];
        Class classAssociatedWithProperty = NSClassFromString(property[@"className"]);
        if ([classAssociatedWithProperty isSubclassOfClass:TWBaseModel.class]) {
            NSManagedObject *subManagedObject = [managedObject valueForKey:propertyName];
            
            TWBaseModel *subModel = [self fillModelFromManagedObject:subManagedObject modelClass:classAssociatedWithProperty];
            [resultModel setValue:subModel forKey:propertyName];
        } else if ([classAssociatedWithProperty isSubclassOfClass:NSSet.class]) {
            NSSet<NSManagedObject *> *subManagedObjects = [managedObject valueForKey:propertyName];
            NSMutableSet<TWBaseModel *> *subModels = [[NSMutableSet alloc] init];
            
            for (NSManagedObject *subManagedObject in subManagedObjects) {
                [subModels addObject:[self fillModelFromManagedObject:subManagedObject modelClass:NSClassFromString(modelNameFrom(subManagedObject.class))]];
            }
            
            [resultModel setValue:subModels.copy forKey:propertyName];
        } else {
            id value = [managedObject valueForKey:propertyName];
            [resultModel setValue:value forKey:propertyName];
        }
    }
    
    return resultModel;
}

static NSString *propertyClassNameWithProperty(objc_property_t property) {
    NSString *propertyAttributes = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
    
    NSArray *splitAttributes = [propertyAttributes componentsSeparatedByString:@","];
    if (splitAttributes.count > 0) {
        NSString *propertyEncodeString = splitAttributes.firstObject;
        NSArray *splitEncodeString = [propertyEncodeString componentsSeparatedByString:@"\""];
        
        return splitEncodeString.count > 2 ? [splitEncodeString objectAtIndex:1] : nil;
    }
    return nil;
}

static NSString *entityNameFrom(Class modelClass) {
    if (![modelClass isSubclassOfClass:TWBaseModel.class]) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"%@Entity", NSStringFromClass(modelClass)];
}

static NSString *modelNameFrom(Class entityClass) {
    return [NSStringFromClass(entityClass) stringByReplacingOccurrencesOfString:@"Entity" withString:@""];
}

static void propertyListOf(Class class, NSMutableArray<NSDictionary *> *propertyArray) {
    if (!propertyArray) {
        return;
    }
    
    if ([NSStringFromClass(class) isEqualToString:NSStringFromClass(TWBaseModel.class)]) {
        return;
    }
    
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(class, &count);
    for (unsigned int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        NSString *className = propertyClassNameWithProperty(property);
        if ([propertyName isKindOfClass:NSString.class] && [className isKindOfClass:NSString.class]) {
            [propertyArray addObject:@{
                                       @"propertyName" : propertyName,
                                       @"className" : className
                                       }];
        }
    }
    free(properties);
    
    propertyListOf(class_getSuperclass(class), propertyArray);
}

static dispatch_queue_t TWGetPersistingWorkQueue() {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.faketwitter.twtwitterdm.persisting", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

static BOOL TWIsPersistingWorkQueue() {
    static const void *queueKey = @"persitingQueue";
    static void *queueContext = @"persitingQueue";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_set_specific(TWGetPersistingWorkQueue(), queueKey, queueContext, NULL);
    });
    return dispatch_get_specific(queueKey) == queueContext;
}

static void TWExecuteOnPersistingQueue(dispatch_block_t task, BOOL sync) {
    if (TWIsPersistingWorkQueue()) {
        task();
    } else if (sync) {        
        dispatch_sync(TWGetPersistingWorkQueue(), task);
    } else {
        dispatch_async(TWGetPersistingWorkQueue(), task);
    }
}

@end
