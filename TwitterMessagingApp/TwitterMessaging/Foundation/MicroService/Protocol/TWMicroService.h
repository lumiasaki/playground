//
//  TWMicroService.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/28.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWMicroServiceLifeCycle.h"

typedef NS_ENUM(NSInteger, TWMicroServiceInitializeLevel) {
    TWMicroServiceInitializeImmediatelyLevel, // init at start phrase
    TWMicroServiceInitializeLazyLevel // init when first find action
};

typedef NS_ENUM(NSInteger, TWMicroServiceIsolateLevel) {
    TWMicroServiceIsolateGlobalLevel,
    TWMicroServiceMicroAppLevel
};

NS_ASSUME_NONNULL_BEGIN

@protocol TWMicroService <NSObject, TWMicroServiceLifeCycle>

@required
+ (NSString *)serviceKey;
+ (TWMicroServiceInitializeLevel)initializeLevel;
+ (TWMicroServiceIsolateLevel)isolateLevel;

@end

NS_ASSUME_NONNULL_END
