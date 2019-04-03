//
//  TWDependencyInstance.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/28.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWDependencyContainer.h"

#define DEPENDENCY_INJECTION_PROPERTY(propertyName, _class) \
- (_class *)propertyName { \
if (!_##propertyName) { \
_##propertyName = [TWDependencyContainer.shared getInstance:NSStringFromClass(_class.class)]; \
} \
return _##propertyName; \
}

#define MARK_AS_DEPENDENCY_INJECTION_ENTITY(key) \
FOUNDATION_EXPORT void TWRegisterDependency(Class clz, NSString *keyOfDependency); \
+ (void)load { \
TWRegisterDependency(self, [NSString stringWithCString:#key encoding:NSUTF8StringEncoding]); \
} \

typedef NS_ENUM(NSInteger, TWDependencyInstanceType) {
    TWDependencyInstanceNormalType,
    TWDependencyInstanceSingletonType
};

NS_ASSUME_NONNULL_BEGIN

@protocol TWDependencyInstance <NSObject>

@required
+ (instancetype)dependencyInstance;
+ (TWDependencyInstanceType)dependencyInstanceType;

@end

NS_ASSUME_NONNULL_END
