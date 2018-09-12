//
//  TWCoreDataStack.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/5.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface TWCoreDataStack : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *context;

+ (instancetype)sharedCoreDataStack;

@end
