//
//  TWMicroServiceLifeCycle.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/28.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TWMicroServiceLifeCycle <NSObject>

@required
- (void)start;

@optional
- (void)onCreated;

@end

NS_ASSUME_NONNULL_END
