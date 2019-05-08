//
//  TWDependencyContainer.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/28.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TWDependencyInstance;

NS_ASSUME_NONNULL_BEGIN

@interface TWDependencyResolver : NSObject

- (id<TWDependencyInstance>)resolve:(NSString *)key;

@end

@interface TWDependencyContainer : NSObject

@property (nonatomic, strong, readonly) TWDependencyResolver *resolver;

+ (instancetype)shared;

- (void)registerDependency:(Class)clz forKey:(NSString *)key initializer:(nullable SEL)initializer arguments:(nullable NSArray *)arguments resolve:(id<TWDependencyInstance>(^ __nullable)(TWDependencyResolver *resolver))resolve;

@end

NS_ASSUME_NONNULL_END
