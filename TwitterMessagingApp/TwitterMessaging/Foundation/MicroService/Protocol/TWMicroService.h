//
//  TWMicroService.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/28.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWMicroServiceLifeCycle.h"

@class TWDependencyContainer;

#define DEPENDENCY_INJECTION_PROPERTY(propertyName, _class) \
- (_class *)propertyName { \
if (!_##propertyName) { \
_##propertyName = [TWDependencyContainer.shared getInstance:NSStringFromClass(_class.class)]; \
} \
return _##propertyName; \
}

#define MARK_AS_DEPENDENCY_INJECTION_ENTITY(key) \
FOUNDATION_EXPORT void TWRegisterDependency(Class clz, NSString *key); \
+ (void)load { \
TWRegisterDependency(self, key); \
}

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
