//
//  TWMicroServiceCenter.m
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/28.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import "TWMicroServiceCenter.h"
#import "TWMicroService.h"
#import "TWMicroServiceContext.h"
#import "TWUtils.h"
#import "TWMicroApplication.h"
#import <objc/runtime.h>
#import "TWMicroService.h"

@interface TWMicroServiceContext (TWMicroServiceCenter)

@property (nonatomic, strong) NSString *contextKey;

@end

@implementation TWMicroServiceContext (TWMicroServiceCenter)

- (void)setContextKey:(NSString *)contextKey {
    if (![contextKey isKindOfClass:NSString.class]) {
        return;
    }
    
    objc_setAssociatedObject(self, @selector(contextKey), contextKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)contextKey {
    return objc_getAssociatedObject(self, _cmd);
}

@end

static NSString *const TW_GLOBAL_SERVICE_CONTEXT_KEY = @"global";

@interface TWMicroServiceCenter ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, TWMicroServiceContext *> *contexts;

@end

@implementation TWMicroServiceCenter

#pragma mark - public

// get a special service context
TWMicroServiceContext *GetGlobalServiceContext() {
    return GetServiceContext(TW_GLOBAL_SERVICE_CONTEXT_KEY);
}

#pragma mark - private

- (instancetype)init {
    if (self = [super init]) {
        _contexts = [[NSMutableDictionary alloc] init];
        
        // sync init services and their associated contexts
        [self setUpServices];
        
        [self runContexts];
    }
    return self;
}

- (void)setUpServices {
    @synchronized (self.contexts) {
        NSArray<Class> *allClasses = [TWUtils getAllClasses];
        
        BOOL containsAppIsolate = NO;
        NSArray<Class> *allServices = [self collectServicesWithClasses:allClasses containsMicroAppIsolateLevel:&containsAppIsolate];
        
        // n^2, but the amount of both of the serivce and context is not a big number, it's acceptable now
        for (TWMicroServiceContext *context in [self collectServiceContextsWithClasses:allClasses createMicroAppContext:containsAppIsolate]) {
            if (![context isKindOfClass:TWMicroServiceContext.class]) {
                continue;
            }
            
            NSString *contextKey = context.contextKey;
            if ([TWUtils stringIsEmpty:contextKey]) {
                continue;
            }
            
            self.contexts[contextKey] = context;
            
            for (Class clz in allServices) {
                [self registerService:clz onContext:context];
            }
        }
    }
}

- (NSArray<Class<TWMicroService>> *)collectServicesWithClasses:(NSArray<Class> *)classes containsMicroAppIsolateLevel:(BOOL *)containsMicroAppIsolateLevel {
    if (![classes isKindOfClass:NSArray.class]) {
        return nil;
    }
    
    BOOL containsAppIsolate = NO;
    
    NSMutableArray<Class<TWMicroService>> *result = [[NSMutableArray alloc] init];
    
    for (Class clz in classes) {
        if ([clz conformsToProtocol:@protocol(TWMicroService)]) {
            [result addObject:clz];
            
            if ([clz respondsToSelector:@selector(isolateLevel)] && [[clz performSelector:@selector(isolateLevel)] integerValue] == TWMicroServiceMicroAppLevel) {
                containsAppIsolate = YES;
            }
        }
    }
    
    *containsMicroAppIsolateLevel = containsAppIsolate;
    
    return result.copy;
}

- (NSArray<TWMicroServiceContext *> *)collectServiceContextsWithClasses:(NSArray<Class> *)classes createMicroAppContext:(BOOL)createMicroAppContext {
    if (![classes isKindOfClass:NSArray.class]) {
        return nil;
    }
    
    NSMutableArray<TWMicroServiceContext *> *result = [[NSMutableArray alloc] init];
    
    TWMicroServiceContext *globalContext = [[TWMicroServiceContext alloc] init];
    globalContext.contextKey = TW_GLOBAL_SERVICE_CONTEXT_KEY;
    
    [result addObject:globalContext];
    
    if (createMicroAppContext) {
        for (Class clz in classes) {
            if ([clz conformsToProtocol:@protocol(TWMicroApplication)]) {
                TWMicroServiceContext *appContext = [[TWMicroServiceContext alloc] init];
                appContext.contextKey = [NSString stringWithUTF8String:class_getName(clz)];
                
                [result addObject:appContext];
            }
        }
    }
    
    return result.copy;
}

- (void)registerService:(Class)serviceClass onContext:(TWMicroServiceContext *)context {
    if (![context isKindOfClass:TWMicroServiceContext.class]) {
        return;
    }
    
    NSAssert([serviceClass respondsToSelector:@selector(initializeLevel)], @"micro service must conform to TWMicroService protocol and must implement initializeLevel method");
    
    NSString *serviceKey = [serviceClass performSelector:@selector(serviceKey)];
    
    TWMicroServiceInitializeLevel initializeLevel;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[serviceClass methodSignatureForSelector:@selector(initializeLevel)]];
    invocation.selector = @selector(initializeLevel);
    invocation.target = serviceClass;
    [invocation invoke];
    [invocation getReturnValue:&initializeLevel];
    
    if (initializeLevel == TWMicroServiceInitializeImmediatelyLevel) {
        id<TWMicroService> service = [[serviceClass alloc] init];
        
        if (![service conformsToProtocol:@protocol(TWMicroService)]) {
            return;
        }
        
        [context addService:service forKey:serviceKey];
    } else if (initializeLevel == TWMicroServiceInitializeLazyLevel) {
        [context addLazyService:^id<TWMicroService> _Nonnull{
            id<TWMicroService> service = [[serviceClass alloc] init];
            
            if (![service conformsToProtocol:@protocol(TWMicroService)]) {
                return nil;
            }
            
            return service;
        } forKey:serviceKey];
    }
}

- (void)runContexts {
    // run context on next runloop, avoid conflicts with dependency injection
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized (self.contexts) {
            for (TWMicroServiceContext *context in self.contexts.allValues) {
                if (![context isKindOfClass:TWMicroServiceContext.class]) {
                    continue;
                }
                
                [context firstTimeBootupServices];
            }
        }
    });
}

static TWMicroServiceContext *GetServiceContext(NSString *key) {
    TWMicroServiceCenter *center = [TWDependencyContainer.shared.resolver resolve:@"TWMicroServiceCenter"];
    return center.contexts[key];
}

#pragma mark - TWDependencyInstance

MARK_AS_DEPENDENCY_INJECTION_ENTITY(TWMicroServiceCenter)

//MARK_AS_DEPENDENCY_INJECTION_ENTITY_WITH_INITIALIZER(TWMicroServiceCenter, @selector(init), nil)

//MARK_AS_DEPENDENCY_INJECTION_ENTITY_WITH_RESOVLER(TWMicroServiceCenter, ^id<TWDependencyInstance>(TWDependencyResolver *resolver) {
//    return [[TWMicroServiceCenter alloc] init];
//});

- (TWDependencyInstanceType)dependencyInstanceType {
    return TWDependencyInstanceSingletonType;
}

@end
