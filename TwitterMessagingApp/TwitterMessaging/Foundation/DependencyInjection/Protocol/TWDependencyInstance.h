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
_##propertyName = [TWDependencyContainer.shared.resolver resolve:NSStringFromClass(_class.class)]; \
} \
return _##propertyName; \
}

#define MARK_AS_DEPENDENCY_INJECTION_ENTITY(key) \
FOUNDATION_EXPORT __attribute__((overloadable)) void TWRegisterDependency(Class clz, NSString *keyOfDependency, SEL initializer); \
+ (void)load { \
TWRegisterDependency(self, [NSString stringWithCString:#key encoding:NSUTF8StringEncoding], @selector(init)); \
} \

#define MARK_AS_DEPENDENCY_INJECTION_ENTITY_WITH_INITIALIZER(key, initializer, arguments) \
FOUNDATION_EXPORT __attribute__((overloadable)) void TWRegisterDependency(Class clz, NSString *keyOfDependency, SEL initializerOfDependency, NSArray *argumentsOfDependency); \
+ (void)load { \
TWRegisterDependency(self, [NSString stringWithCString:#key encoding:NSUTF8StringEncoding], initializer, arguments); \
} \

#define MARK_AS_DEPENDENCY_INJECTION_ENTITY_WITH_RESOVLER(key, resolveBlock) \
FOUNDATION_EXPORT __attribute__((overloadable)) void TWRegisterDependency(Class clz, NSString *keyOfDependency, id<TWDependencyInstance>(^resolve)(TWDependencyResolver *resolver)); \
+ (void)load { \
TWRegisterDependency(self, [NSString stringWithCString:#key encoding:NSUTF8StringEncoding], resolveBlock); \
} \

typedef NS_ENUM(NSInteger, TWDependencyInstanceType) {
    TWDependencyInstanceNormalType,
    TWDependencyInstanceSingletonType
};

NS_ASSUME_NONNULL_BEGIN

@protocol TWDependencyInstance <NSObject>

@required
- (TWDependencyInstanceType)dependencyInstanceType;

@end

NS_ASSUME_NONNULL_END
