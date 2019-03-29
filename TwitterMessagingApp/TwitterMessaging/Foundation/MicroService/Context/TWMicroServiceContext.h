//
//  TWMicroServiceContext.h
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/28.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TWMicroService;

NS_ASSUME_NONNULL_BEGIN

@interface TWMicroServiceContext : NSObject

- (id<TWMicroService>)findService:(NSString *)serviceKey;

@end

@interface TWMicroServiceContext (TWBootupServices)

- (void)firstTimeBootupServices;

@end

@interface TWMicroServiceContext (TWAddServices)

// not thread safe
- (void)addService:(id<TWMicroService>)service forKey:(NSString *)key;
- (void)addLazyService:(id<TWMicroService>(^)(void))lazyServiceBlock forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
