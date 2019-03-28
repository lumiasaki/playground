//
//  TWDependencyInstance.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/28.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TWDependencyInstanceType) {
    TWDependencyInstanceNormalType,
    TWDependencyInstanceSingletonType
};

NS_ASSUME_NONNULL_BEGIN

@protocol TWDependencyInstance <NSObject>

@required
+ (instancetype)dependencyInstance;
+ (TWDependencyInstanceType)dependencyInstanceType;

#pragma mark - unavailable

- (instancetype)init __attribute__((unavailable("conforms to TWDependencyInstance protocol, get instance from dependency injection function")));

@end

NS_ASSUME_NONNULL_END
