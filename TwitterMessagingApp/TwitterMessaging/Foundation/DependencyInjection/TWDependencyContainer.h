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

@interface TWDependencyContainer : NSObject

+ (instancetype)shared;
- (id<TWDependencyInstance>)getInstance:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
