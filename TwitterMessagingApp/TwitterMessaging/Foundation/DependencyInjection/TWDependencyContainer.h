//
//  TWDependencyContainer.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/28.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TWDependencyInstance;

#define DEPENDENCY_INJECTION_VAR(propertyName, _class) \
- (_class *)propertyName { \
  if (!_##propertyName) { \
    _##propertyName = [TWDependencyInjection.shared getInstance:NSStringFromClass(_class.class)]; \
  } \
  return _##propertyName; \
}

#define MARK_AS_DEPENDENCY_INJECTION_ENTITY(key) \
FOUNDATION_EXPORT void TWRegisterDependency(Class clz, NSString *key); \
+ (void)load { \
TWRegisterDependency(self, key); \
}

NS_ASSUME_NONNULL_BEGIN

@interface TWDependencyContainer : NSObject

+ (instancetype)shared;
- (id)getInstance:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
