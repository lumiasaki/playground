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

@interface TWDependencyContainer ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, Class> *dependencies;

@end

@implementation TWDependencyContainer

#pragma mark - public

void TWRegisterDependency(Class clz, NSString *key) {
    [TWDependencyContainer.shared registerDependency:clz forKey:key];
}

+ (instancetype)shared {
    static TWDependencyContainer *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TWDependencyContainer alloc] init];
    });
    return instance;
}

- (id)getInstance:(NSString *)key {
    if ([TWUtils stringIsEmpty:key]) {
        return nil;
    }

    Class cls = self.dependencies[key];

    if (cls) {
        return [self getInstanceFromClass:cls];
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

- (void)registerDependency:(Class)clz forKey:(NSString *)key {
    if (![key isKindOfClass:NSString.class]) {
        return;
    }

    @synchronized (self.dependencies) {
        [self.dependencies tw_safeSetObject:clz forKey:key];
    }
    
    // for some really special cases, need init at +load phrase
    SEL fastInitializedSelector = NSSelectorFromString(@"dependencyFastInitialized");
    if ([clz respondsToSelector:fastInitializedSelector]) {
        BOOL result;
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[clz methodSignatureForSelector:fastInitializedSelector]];
        invocation.selector = fastInitializedSelector;
        invocation.target = clz;
        [invocation invoke];
        [invocation getReturnValue:&result];
        
        if (result) {
            (void)[self getInstanceFromClass:clz];
        }
    }
}

- (id)getInstanceFromClass:(Class<TWDependencyInstance>)clz {
    if (![clz conformsToProtocol:@protocol(TWDependencyInstance)]) {
        return nil;
    }
    
    return [clz performSelector:@selector(dependencyInstance)];
}

@end
