//
//  TWMicroServiceContext.m
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/28.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import "TWMicroServiceContext.h"
#import "TWMicroService.h"
#import "NSMutableDictionary+TWExtension.h"
#import "TWUtils.h"
#import <objc/runtime.h>

@implementation TWMicroServiceContext (TWAddServices)

- (NSMutableDictionary<NSString *, id> *)services {
    NSMutableDictionary<NSString *, id> *services = objc_getAssociatedObject(self, _cmd);
    if (![services isKindOfClass:NSMutableDictionary.class]) {
        services = [[NSMutableDictionary alloc] init];
        
        objc_setAssociatedObject(self, _cmd, services, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return services;
}

- (void)addService:(id<TWMicroService>)service forKey:(nonnull NSString *)key {
    NSAssert(![TWUtils stringIsEmpty:key], @"key can't be nil");
    NSAssert([service conformsToProtocol:@protocol(TWMicroService)], @"service must conforms to TWMicroService");
    
    [self.services tw_safeSetObject:service forKey:key];
}

- (void)addLazyService:(id<TWMicroService>  _Nonnull (^)(void))lazyServiceBlock forKey:(nonnull NSString *)key {
    NSAssert(![TWUtils stringIsEmpty:key], @"key can't be nil");
    NSAssert(lazyServiceBlock, @"lazyServiceBlock must not be nil");
    
    [self.services tw_safeSetObject:lazyServiceBlock forKey:key];
}

@end

@implementation TWMicroServiceContext (TWBootupServices)

#pragma mark - public

- (void)firstTimeBootupServices {
    for (id<TWMicroService> service in self.services.allValues) {
        // means it is initialized service, not lazy service
        if ([service conformsToProtocol:@protocol(TWMicroService)]) {
            [self bootupService:service];
        }
    }
}

#pragma mark - private

- (void)bootupService:(id<TWMicroService>)service {
    if (![service conformsToProtocol:@protocol(TWMicroService)]) {
        return;
    }
    
    [service onCreated];
    
    [service start];
}

@end

@implementation TWMicroServiceContext

- (id<TWMicroService>)findService:(NSString *)serviceKey {
    if ([TWUtils stringIsEmpty:serviceKey]) {
        return nil;
    }
    
    {
        id<TWMicroService> service = self.services[serviceKey];
        if ([service conformsToProtocol:@protocol(TWMicroService)]) {
            // do not boot up because it is immediate type service or second find time lazy service
            return service;
        }
    }
    
    {
        @synchronized (self.services) {
            // indicate lazy service
            id<TWMicroService>(^lazyBlock)(void) = self.services[serviceKey];
            id<TWMicroService> service = lazyBlock();
            
            // run service life cycle when first time find it
            [self bootupService:service];
            
            // replace it, then next time it will be found directly
            self.services[serviceKey] = service;
            
            return service;
        }
    }
}

@end
