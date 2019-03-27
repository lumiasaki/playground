//
//  TWPersisting.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWBaseModel.h"

// all these operations are universal for every data persisting process, no matter the details of implementation under the persistence layer, Core Data, Realm, SQLite or even a simple Key-Value storage.
@protocol TWPersisting <NSObject>

// insert an object into database, until you invoke save() method.
- (void)insertObject:(TWBaseModel *)object;

// select objects by predicate.
- (NSSet<TWBaseModel *> *)selectObjects:(Class)objectClass predicate:(NSPredicate *)predicate;

// update an object in database, persist it until you invoke save() method.
- (void)updateObject:(TWBaseModel *)object;

// delete an object from database, persist it until you invoke save method.
- (void)deleteObject:(TWBaseModel *)object;

// persist all changes.
- (void)save;

@end
