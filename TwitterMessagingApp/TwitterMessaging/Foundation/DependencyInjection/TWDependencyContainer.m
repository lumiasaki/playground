//
//  TWDependencyContainer.m
//  TwitterMessaging
//
//  Created by tianren.zhu on 2019/3/28.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

#import "TWDependencyContainer.h"
#import "TWDependencyInstance.h"
#import "NSMutableDictionary+TWExtension.h"
#import "TWUtils.h"
#import <objc/runtime.h>

@interface _TWDependencyEntity : NSObject

@property (nonatomic, assign, nonnull) Class classForDependencyInjection;
@property (nonatomic, assign, nonnull) SEL initializer;
@property (nonatomic, strong, nonnull) NSString *key;
@property (nonatomic, strong, nullable) NSArray *arguments;
@property (nonatomic, copy, nullable) id<TWDependencyInstance>(^resolveBlock)(TWDependencyResolver *resolver);

@end

@interface _TWDependencyEntity (TWSingleton)

@property (nonatomic, strong, nullable) id<TWDependencyInstance> associatedSingleton;

@end

@implementation _TWDependencyEntity

- (void)setAssociatedSingleton:(id<TWDependencyInstance>)associatedSingleton {
    objc_setAssociatedObject(self, @selector(associatedSingleton), associatedSingleton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<TWDependencyInstance>)associatedSingleton {
    return objc_getAssociatedObject(self, _cmd);
}

@end

@interface TWDependencyContainer ()

@property (nonatomic, strong, readwrite) TWDependencyResolver *resolver;

@property (nonatomic, strong) NSMutableDictionary<NSString *, _TWDependencyEntity *> *dependencies;

@end

@implementation TWDependencyContainer

#pragma mark - public

__attribute__((overloadable))
void TWRegisterDependency(Class clz, NSString *key, SEL initializer) {
    [TWDependencyContainer.shared registerDependency:clz forKey:key initializer:initializer arguments:nil resolve:nil];
}

__attribute__((overloadable))
void TWRegisterDependency(Class clz, NSString *key, SEL initializer, NSArray *arguments) {
    [TWDependencyContainer.shared registerDependency:clz forKey:key initializer:initializer arguments:arguments resolve:nil];
}

__attribute__((overloadable))
void TWRegisterDependency(Class clz, NSString *key, id<TWDependencyInstance>(^resolve)(TWDependencyResolver *resolver)) {
    [TWDependencyContainer.shared registerDependency:clz forKey:key initializer:NULL arguments:nil resolve:resolve];
}

+ (instancetype)shared {
    static TWDependencyContainer *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TWDependencyContainer alloc] init];
    });
    return instance;
}

- (id<TWDependencyInstance>)getInstance:(NSString *)key {
    if ([TWUtils stringIsEmpty:key]) {
        return nil;
    }

    _TWDependencyEntity *entity = self.dependencies[key];
    
    if ([entity isKindOfClass:_TWDependencyEntity.class]) {
        return [self getInstanceFromEntity:entity];
    }
    
    return nil;
}

#pragma mark - private

- (instancetype)init {
    if (self = [super init]) {
        _dependencies = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)registerDependency:(Class)clz forKey:(NSString *)key initializer:(SEL)initializer arguments:(NSArray *)arguments resolve:(nullable id<TWDependencyInstance>  _Nonnull (^)(TWDependencyResolver * _Nonnull))resolve {
    NSAssert(clz, @"class can't be nil");
    NSAssert(![TWUtils stringIsEmpty:key], @"key can't be nil");
    
    _TWDependencyEntity *entity = [[_TWDependencyEntity alloc] init];
    
    entity.classForDependencyInjection = clz;
    entity.key = key;
    entity.initializer = initializer;
    entity.arguments = arguments;
    entity.resolveBlock = resolve;
    
    @synchronized (self.dependencies) {
        [self.dependencies tw_safeSetObject:entity forKey:key];
    }
}

- (id<TWDependencyInstance>)getInstanceFromEntity:(_TWDependencyEntity *)entity {
    if (entity.classForDependencyInjection == NULL) {
        return nil;
    }
    
    if (entity.initializer == NULL && !entity.resolveBlock) {
        return nil;
    }
    
    if ([entity.associatedSingleton conformsToProtocol:@protocol(TWDependencyInstance)] && entity.associatedSingleton.dependencyInstanceType == TWDependencyInstanceSingletonType) {
        return entity.associatedSingleton;
    }
    
    id<TWDependencyInstance> result;
    if (!entity.resolveBlock) {
        result = [self getInstanceFromClass:entity.classForDependencyInjection initializer:entity.initializer arguments:entity.arguments];
    } else {
        result = [self getInstanceFromResolve:entity.resolveBlock];
    }
    
    if (result.dependencyInstanceType == TWDependencyInstanceSingletonType) {
        entity.associatedSingleton = result;
    }
    
    return result;
}

- (id<TWDependencyInstance>)getInstanceFromClass:(Class)clz initializer:(SEL)initializer arguments:(NSArray *)arguments {
    id<TWDependencyInstance> result;
    id allocedInstance = [clz alloc];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[clz methodSignatureForSelector:initializer]];
    invocation.selector = initializer;
    invocation.target = allocedInstance;
    
    if ([arguments isKindOfClass:NSArray.class]) {
        [arguments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isKindOfClass:NSNull.class]) {
                // only support object now
                [invocation setArgument:&obj atIndex:idx + 2];
            }
        }];
    }
    
    [invocation invoke];
    [invocation getReturnValue:&result];
    
    if ([result conformsToProtocol:@protocol(TWDependencyInstance)]) {
        return result;
    }
    
    return nil;
}

- (id<TWDependencyInstance>)getInstanceFromResolve:(id<TWDependencyInstance>(^)(TWDependencyResolver *))resolveBlock {
    if (resolveBlock) {
        return resolveBlock(self.resolver);
    }
    
    return nil;
}

#pragma mark - getter

- (TWDependencyResolver *)resolver {
    if (!_resolver) {
        _resolver = [[TWDependencyResolver alloc] init];
        [_resolver setValue:self forKey:@"container"];
    }
    return _resolver;
}

@end

@interface TWDependencyResolver ()

@property (nonatomic, weak) TWDependencyContainer *container;

@end

@implementation TWDependencyResolver

- (id<TWDependencyInstance>)resolve:(NSString *)key {
    id<TWDependencyInstance> result = [self.container getInstance:key];
    
    if ([result conformsToProtocol:@protocol(TWDependencyInstance)]) {
        return result;
    }
    
    return nil;
}

@end
